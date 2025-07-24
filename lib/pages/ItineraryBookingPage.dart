import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:profile_test_isp/pages/ItineraryPage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// import '../models/ItineraryDateModel.dart'; // Ensure this path is correct

// Define the BookingDate model based on your strict requirement
// If this is in a separate file, ensure that file's content matches this.
class BookingDate {
  final String date;
  BookingDate({required this.date});

  factory BookingDate.fromJson(Map<String, dynamic> json) {
    return BookingDate(
      date:
          json['start']?.toString() ??
          'No Booking Date', // Assuming API sends 'start'
    );
  }
}

class ItineraryBookingPage extends StatefulWidget {
  final String slug;
  final double price; // The price per person is now available
  const ItineraryBookingPage({
    super.key,
    required this.slug,
    required this.price,
  });

  @override
  State<ItineraryBookingPage> createState() => _ItineraryBookingPageState();
}

class _ItineraryBookingPageState extends State<ItineraryBookingPage> {
  List<BookingDate> _availableDates = []; // List of available date objects
  String?
  _selectedAvailableDate; // Stores the date string of the *single* selected available option

  // Calendar related state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // The date selected on the calendar itself
  String?
  _currentCalendarSelectedDateString; // Formatted string of the calendar selected date

  bool _isLoading = true;
  String? _errorMessage;

  // Pax and Price related state
  int _numberOfPeople = 1; // Default to 1 person
  late double _totalPrice; // To store the calculated total price

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _currentCalendarSelectedDateString = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedDay!);
    _updateTotalPrice(); // Initialize total price
    _fetchAvailability();
  }

  void _updateTotalPrice() {
    setState(() {
      _totalPrice = widget.price * _numberOfPeople;
    });
  }

  Future<void> _fetchAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _availableDates = []; // Clear previous dates
      _selectedAvailableDate = null; // Clear selection when fetching new dates
    });

    if (_currentCalendarSelectedDateString == null) {
      setState(() {
        _errorMessage = 'Please select a date from the calendar.';
        _isLoading = false;
      });
      return;
    }

    final encodedSlug = Uri.encodeComponent(widget.slug);
    final encodedDate = Uri.encodeComponent(
      _currentCalendarSelectedDateString!,
    );

    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/attraction/detail/avalibility'
      '?slug=$encodedSlug&date=$encodedDate',
    );

    try {
      final response = await http.get(uri);
      print('Response status for availability: ${response.statusCode}');
      print('Response body for availability: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final datesData = List<Map<String, dynamic>>.from(data['data'] ?? []);

        setState(() {
          _availableDates = datesData
              .map((item) => BookingDate.fromJson(item))
              .toList();
          if (_availableDates.isEmpty) {
            _errorMessage = 'No availability found for this date.';
          } else {
            // Optional: Auto-select the first available date if any
            _selectedAvailableDate = _availableDates.first.date;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load availability: ${response.statusCode}';
          _isLoading = false;
        });
        throw Exception('Failed to load availability: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching availability: $e';
        _isLoading = false;
      });
      print('Exception fetching availability: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _currentCalendarSelectedDateString = DateFormat(
          'yyyy-MM-dd',
        ).format(selectedDay);
      });
      _fetchAvailability(); // Automatically fetch availability for the new date
    }
  }

  void _selectAvailableDate(String? date) {
    setState(() {
      _selectedAvailableDate = date;
    });
  }

  void _checkout() async {
    if (_selectedAvailableDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an available date to proceed."),
        ),
      );
      return;
    }

    if (_numberOfPeople <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a valid number of people (at least 1)."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You have booked the itinerary good job!"), // Modified text
          ],
        ),
        actions: [
          // Removed Cancel button
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dismiss dialog
              await _performCheckoutRequest(
                _selectedAvailableDate!,
                _numberOfPeople, // Pass the number of people
              );
              // Navigate to ItineraryPage after successful checkout
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ItineraryPage()),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _performCheckoutRequest(String dateToCheckout, int pax) async {
    final uri = Uri.parse('http://10.0.2.2:3000/api/attraction/checkout');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'slug': widget.slug,
          'date': dateToCheckout, // Send the single selected date
          'pax': pax, // Send the number of people
        }),
      );
      print("Checkout Payload: Date: $dateToCheckout, Pax: $pax");
      print('Checkout response status: ${response.statusCode}');
      print('Checkout response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking successful for selected date! 🎉"),
          ),
        );
        setState(() {
          _selectedAvailableDate =
              null; // Clear selection after successful checkout
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${response.body}")),
        );
      }
    } catch (e) {
      print('Checkout error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Checkout error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Booking Date"),
        backgroundColor: const Color(
          0xFF780000,
        ), // Changed from Colors.deepPurple
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align content to start
                children: [
                  // ------------------- Number of People Input with Stepper -------------------
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Number of People (Pax)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(
                                      0xFF780000,
                                    ), // Changed from Colors.deepPurple
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_numberOfPeople > 1) {
                                        _numberOfPeople--;
                                        _updateTotalPrice();
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '$_numberOfPeople',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(
                                      0xFF780000,
                                    ), // Changed from Colors.deepPurple
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _numberOfPeople++;
                                      _updateTotalPrice();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ------------------- Price Display -------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: const Color(
                        0x1A780000,
                      ), // Lighter red background (approx. 10% opacity of 0xFF780000)
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Price:",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFF780000,
                                ), // Changed from Colors.deepPurple
                              ),
                            ),
                            Text(
                              '\$${_totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFFD32F2F,
                                ), // A brighter red for emphasis
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ------------------- Calendar Selection -------------------
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2026, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      onDaySelected: _onDaySelected,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: const Color(
                            0x4D780000,
                          ), // Red with 30% opacity
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(
                            0xFF780000,
                          ), // Changed from Colors.deepPurple
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(color: Colors.white),
                        weekendTextStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ------------------- Availability List (Radio Buttons) -------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _currentCalendarSelectedDateString != null
                          ? 'Available Dates for $_currentCalendarSelectedDateString:'
                          : 'Select a date from the calendar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(
                              0xFF780000,
                            ), // Changed from Colors.deepPurple
                          ),
                        )
                      : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : _availableDates.isEmpty
                      ? const Center(
                          child: Text("No availability found for this date."),
                        )
                      : ListView.builder(
                          shrinkWrap: true, // Important for nested ListView
                          physics:
                              const NeverScrollableScrollPhysics(), // Important for nested ListView
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _availableDates.length,
                          itemBuilder: (context, index) {
                            final bookingDate = _availableDates[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 2,
                              color: _selectedAvailableDate == bookingDate.date
                                  ? const Color(
                                      0x1A780000,
                                    ) // Red with 10% opacity
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color:
                                      _selectedAvailableDate == bookingDate.date
                                      ? const Color(
                                          0xFF780000,
                                        ) // Changed from Colors.deepPurple
                                      : Colors.grey.shade300,
                                  width:
                                      _selectedAvailableDate == bookingDate.date
                                      ? 2.0
                                      : 1.0,
                                ),
                              ),
                              child: RadioListTile<String>(
                                title: Text(
                                  'Available: ${bookingDate.date}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .green, // Kept green for "Available" text
                                  ),
                                ),
                                value: bookingDate
                                    .date, // The value of this radio button
                                groupValue:
                                    _selectedAvailableDate, // The currently selected value in the group
                                onChanged:
                                    _selectAvailableDate, // Callback when this radio button is selected
                                activeColor: const Color(
                                  0xFF780000,
                                ), // Changed from Colors.deepPurple
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ------------------- Checkout Button (Fixed at Bottom) -------------------
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ElevatedButton(
              // Enable only if a single date is selected
              onPressed: _selectedAvailableDate != null && _numberOfPeople > 0
                  ? _checkout
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF780000,
                ), // Changed from Colors.deepOrangeAccent
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Proceed to Checkout"),
            ),
          ),
        ],
      ),
    );
  }
}
