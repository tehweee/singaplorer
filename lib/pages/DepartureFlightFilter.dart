import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterPage extends StatefulWidget {
  final String to;
  final String depart; // This will be '2025-07-25' from DepartureFlightPage
  final String cabin;
  final String sort;
  final String pax;

  const FilterPage({
    super.key,
    required this.to,
    required this.depart,
    required this.cabin,
    required this.sort,
    this.pax = '1',
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late TextEditingController _toController;
  late TextEditingController _paxController;
  late String _selectedCabin;
  late String _selectedSort;
  late DateTime _selectedDate;

  final _cabinOptions = ['ECONOMY', 'PREMIUM_ECONOMY', 'BUSINESS', 'FIRST'];
  final _sortOptions = ['BEST', 'CHEAPEST', 'FASTEST'];

  @override
  void initState() {
    super.initState();
    _toController = TextEditingController(text: widget.to);
    _paxController = TextEditingController(text: widget.pax);
    _selectedCabin = widget.cabin;
    _selectedSort = widget.sort;
    // Safely parse date. Given widget.depart is '2025-07-25', _selectedDate will be July 25, 2025.
    _selectedDate = DateTime.tryParse(widget.depart) ?? DateTime.now();
  }

  @override
  void dispose() {
    _toController.dispose();
    _paxController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // Pop the context and return the updated filter values
    Navigator.pop(context, {
      'to': _toController.text,
      'depart': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'cabin': _selectedCabin,
      'sort': _selectedSort,
      'pax': _paxController.text,
    });
  }

  // Helper method for consistent input field decoration
  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black54), // Subtle label color
      floatingLabelStyle: const TextStyle(
        color: Color(0xFFAA0000),
      ), // Red when focused
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFAA0000),
          width: 2,
        ), // Red focus border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ), // Light grey border
      ),
      border: OutlineInputBorder(
        // Default border
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current date for comparison, if you want to style today's date differently
    final DateTime today =
        DateTime.now(); // Current time is Friday, July 25, 2025 at 3:09:20 AM +08

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Filters',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFAA0000), // Primary red color
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      // Apply the themed background to the body using a Container with ClipRRect for rounded corners
      body: Container(
        color: const Color(
          0xFFAA0000,
        ), // Red background for the top part of the body
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            color: Colors.white, // White background for the main content area
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ), // Adjust for padding
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _toController,
                            decoration: _buildInputDecoration(
                              'To (e.g. SIN.AIRPORT)',
                            ), // Updated example
                          ),
                          const SizedBox(height: 16), // Increased spacing
                          TextField(
                            controller: _paxController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(
                              'Number of Passengers',
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedCabin,
                            items: _cabinOptions
                                .map(
                                  (cabin) => DropdownMenuItem(
                                    value: cabin,
                                    child: Text(cabin),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCabin = value!),
                            decoration: _buildInputDecoration('Cabin Class'),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ), // Text style for selected value
                            iconEnabledColor: const Color(
                              0xFFAA0000,
                            ), // Red dropdown icon
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedSort,
                            items: _sortOptions
                                .map(
                                  (sort) => DropdownMenuItem(
                                    value: sort,
                                    child: Text(sort),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedSort = value!),
                            decoration: _buildInputDecoration('Sort By'),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            iconEnabledColor: const Color(0xFFAA0000),
                          ),
                          const SizedBox(
                            height: 24,
                          ), // More space before date picker
                          const Text(
                            'Departure Date',
                            style: TextStyle(
                              fontSize:
                                  18, // Slightly larger font for section title
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Calendar background
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                // Optional subtle shadow for the calendar container
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height:
                                  320, // Adjusted height for calendar for better fit
                              width: double.infinity,
                              child: Theme(
                                // Apply theme to CalendarDatePicker for consistent colors
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(
                                      0xFFAA0000,
                                    ), // Selected date circle color
                                    onPrimary: Colors
                                        .redAccent, // Text color on selected date
                                    onSurface: Colors
                                        .black87, // Text color for non-selected dates
                                    surface: Colors
                                        .white, // Background of the calendar itself
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(
                                        0xFFAA0000,
                                      ), // Month/year and next/prev month buttons
                                    ),
                                  ),
                                  textTheme: Theme.of(context).textTheme
                                      .copyWith(
                                        bodyLarge: TextStyle(
                                          color: Colors.black87,
                                        ), // Default text color for days
                                        bodyMedium: TextStyle(
                                          color: Colors.black54,
                                        ), // Faint text for disabled days
                                        labelLarge: TextStyle(
                                          color: Color(0xFFAA0000),
                                          fontWeight: FontWeight.bold,
                                        ), // Weekday labels (S, M, T...)
                                      ),
                                ),
                                child: CalendarDatePicker(
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ), // Allow 2 years into future
                                  onDateChanged: (date) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Spacer(), // Pushes the button to the bottom
                          const SizedBox(height: 24), // Space before the button
                          SizedBox(
                            width:
                                double.infinity, // Make the button full width
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFAA0000,
                                ), // Red button
                                foregroundColor: Colors.white, // White text
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ), // More vertical padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // Rounded corners for button
                                ),
                                elevation: 5, // A bit of shadow for prominence
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
