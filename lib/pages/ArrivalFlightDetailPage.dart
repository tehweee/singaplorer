// ArrivalFlightDetailPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/FlightDetailModel.dart'; // Ensure your FlightDetail class is here
import 'dart:math';
import 'package:intl/intl.dart'; // Import for date formatting
import 'HomePage.dart'; // Import your HomePage - assuming this is where the user goes after booking arrival

class ArrivalFlightDetailPage extends StatefulWidget {
  final String flightDetail;
  final String totalPrice;
  final String pax;

  const ArrivalFlightDetailPage({
    super.key,
    required this.flightDetail,
    required this.totalPrice,
    required this.pax,
  });

  @override
  State<ArrivalFlightDetailPage> createState() =>
      _ArrivalFlightDetailPageState();
}

class _ArrivalFlightDetailPageState extends State<ArrivalFlightDetailPage> {
  List<FlightDetail> _flightDetail = [];
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    setState(() {
      _isLoading = true; // Set loading to true when fetching starts
    });

    final encodedToken = Uri.encodeComponent(widget.flightDetail);

    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/flights/detail?token=$encodedToken',
    );

    try {
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _flightDetail = [FlightDetail.fromJson(data['data'])]; // wrap in list
        });
      } else {
        // Handle error: show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load flight detail: ${response.statusCode}',
            ),
          ),
        );
        throw Exception('Failed to load flight detail');
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching flight details: $e')),
      );
    } finally {
      setState(() {
        _isLoading =
            false; // Set loading to false regardless of success or failure
      });
    }
  }

  // Helper function to format the date and time string (e.g., "Jul 25, 2025 at 4:10 PM")
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);
    } catch (e) {
      print('Error parsing date time: $e');
      return dateTimeString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flight Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFAA0000), // Primary red color
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
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
            child:
                _isLoading // Use the loading state
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFAA0000)),
                  ) // Red indicator
                : _flightDetail.isEmpty
                ? const Center(
                    child: Text(
                      'No flight details found.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Padding around the list
                    itemCount: _flightDetail.length,
                    itemBuilder: (context, index) {
                      final flight = _flightDetail[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Slightly more rounded corners
                        ),
                        elevation: 8, // Increased elevation for more pop
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ), // Adjusted margin
                        child: Padding(
                          padding: const EdgeInsets.all(
                            20.0,
                          ), // Increased padding inside card
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Flight departure/arrival information (Bold and bigger)
                              _buildFlightLocationRow(
                                flight.departureAirport,
                                flight.departureCountry,
                                flight.arrivalAirport,
                                flight.arrivalCountry,
                              ),
                              const Divider(
                                height: 30, // More space after airports
                                thickness: 1,
                                color: Colors.grey,
                              ), // Separator
                              // Display formatted date and time
                              _infoRow(
                                'Departure:',
                                _formatDateTime(flight.departureTime),
                              ),
                              _infoRow(
                                'Arrival:',
                                _formatDateTime(flight.arrivalTime),
                              ),
                              const SizedBox(height: 15),
                              _infoRow(
                                'Price:',
                                '\$${double.parse(flight.price).toStringAsFixed(2)}',
                                isBold: true,
                                valueColor: const Color(0xFFAA0000),
                              ), // Format price, make red
                              _infoRow(
                                'Cabin Class:',
                                flight.cabinClass.replaceAll(
                                  '_',
                                  ' ',
                                ), // Make cabin class more readable
                                isBold: true,
                                valueColor: Colors
                                    .deepOrange, // A different accent color for cabin
                              ),
                              _infoRow(
                                'Passengers:',
                                widget.pax,
                              ), // Display pax from widget
                              _infoRow(
                                'Total Price:',
                                '\$${double.parse(widget.totalPrice).toStringAsFixed(2)}',
                                isBold: true,
                                valueColor: const Color(0xFFAA0000),
                              ), // Display total price
                              const SizedBox(
                                height: 30,
                              ), // More space before button
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _checkout(
                                      flight.departureCountry,
                                      flight.departureAirport,
                                      flight
                                          .departureTime, // Send original string to backend
                                      flight
                                          .arrivalTime, // Send original string to backend
                                      flight.price,
                                      flight.cabinClass,
                                      widget.pax,
                                      widget.totalPrice,
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          'Booking Successful! ✅',
                                          style: TextStyle(
                                            color: Color(0xFFAA0000),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: const Text(
                                          'Your flight has been successfully booked.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                              ); // Dismiss the dialog
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(), // Navigates to HomePage after arrival flight booking
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Return to Home',
                                              style: TextStyle(
                                                color: Color(0xFFAA0000),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFAA0000,
                                    ), // Red button
                                    foregroundColor: Colors.white, // White text
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ), // More padding
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ), // Larger, bolder text
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Book Flight',
                                  ), // Changed text to be more explicit
                                ),
                              ),
                            ],
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

  Widget _infoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ), // Increased vertical padding for more space
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Make label bold
              fontSize: 16, // Slightly larger label font
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12), // Increased space between label and value
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 18, // Bigger value font
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right, // Align value to the right
            ),
          ),
        ],
      ),
    );
  }

  // Updated widget for origin and destination with bigger and bolder text
  Widget _buildFlightLocationRow(
    String departureAirport,
    String departureCountry,
    String arrivalAirport,
    String arrivalCountry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.flight_takeoff,
              color: Color(0xFFAA0000),
              size: 28, // Bigger icon
            ),
            const SizedBox(width: 12), // More space
            Expanded(
              child: Text(
                '$departureAirport, $departureCountry',
                style: const TextStyle(
                  fontSize: 20, // Bigger airport/country text
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(
            'to',
            style: TextStyle(
              fontSize: 16, // Slightly bigger 'to'
              color: Colors.grey, // More subtle 'to' color
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.flight_land,
              color: Color(0xFFAA0000),
              size: 28,
            ), // Bigger icon
            const SizedBox(width: 12), // More space
            Expanded(
              child: Text(
                '$arrivalAirport, $arrivalCountry',
                style: const TextStyle(
                  fontSize: 20, // Bigger airport/country text
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _checkout(
    String country,
    String airport,
    String departTime, // This remains the original string for backend
    String arrivalTime, // This remains the original string for backend
    String price,
    String cabin,
    String pax,
    String totalPrice,
  ) async {
    final uri = Uri.parse('http://10.0.2.2:3000/api/arrive/flights/checkout');

    try {
      String secretKey = generateSecretKey(16);

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': widget.flightDetail,
          'fromCountry': country,
          'fromAirport': airport,
          'departureTime': departTime,
          'arrivalTime': arrivalTime,
          'pricePerPax': price,
          'cabinClass': cabin,
          'pax': pax, // Included pax
          'totalPrice': totalPrice, // Included totalPrice
        }),
      );

      print('Checkout response status: ${response.statusCode}');
      print('Checkout response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Checkout successful!');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Checkout error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during checkout: $e')));
    }
  }

  String generateSecretKey(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (index) => characters[random.nextInt(characters.length)],
    ).join();
  }
}
