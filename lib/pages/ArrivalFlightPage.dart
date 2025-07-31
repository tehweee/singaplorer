import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:profile_test_isp/pages/ArrivalFlightFilter.dart';
import '../models/FlightModel.dart';
import 'ArrivalFlightDetailPage.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ArrivalFlightPage extends StatefulWidget {
  const ArrivalFlightPage({super.key});

  @override
  State<ArrivalFlightPage> createState() => _ArrivalFlightPageState();
}

class _ArrivalFlightPageState extends State<ArrivalFlightPage> {
  List<Flight> _flights = [];

  // Default values for initial search
  String _from = 'SIN.AIRPORT'; // Changi Airport
  String _to = 'LHR.AIRPORT'; // London Heathrow Airport
  String _depart = DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now()); // Current date as per context
  String _selectedCabin = 'ECONOMY';
  String _selectedSort = 'BEST';
  String _pax = '1';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFlights(); // Fetch flights when the page initializes
  }

  // Helper function to format the full date and time string
  String _formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      // Example format: "Jul 25, 2025, 4:10 PM"
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    } catch (e) {
      print('Error parsing date time: $e');
      return dateTimeString; // Return original if parsing fails
    }
  }

  // Helper function to format only the time (e.g., "16:10" to "4:10 PM")
  String _formatTimeOnly(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('h:mm a').format(dateTime); // e.g., "4:10 PM"
    } catch (e) {
      print('Error parsing time: $e');
      // Fallback to substring if full parsing fails, assuming 'T' separator
      if (dateTimeString.contains('T')) {
        return dateTimeString.split('T')[1].substring(0, 5); // Just "HH:MM"
      }
      return dateTimeString; // Return original if no 'T' or other issues
    }
  }

  Future<void> _fetchFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Constructing the URI for the API call
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/flights'
      '?from=$_from'
      '&to=$_to'
      '&depart=$_depart'
      '&cabinClass=$_selectedCabin'
      '&sort=$_selectedSort',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final flights = List<Map<String, dynamic>>.from(data['data'] ?? []);
        setState(() {
          _flights = flights.map((item) => Flight.fromJson(item)).toList();
        });
      } else {
        // Handle non-200 responses
        setState(() {
          _error =
              'Failed to load flights. Status code: ${response.statusCode}. Please try again.';
          _flights = [];
        });
        print('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      setState(() {
        _error =
            'Error connecting to the server: $e. Please check your internet connection or try again later.';
        _flights = [];
      });
      print('Network/Parsing Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFilterPage() async {
    // Navigate to the filter page and await results
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArrivalFilterPage(
          to: _to,
          depart: _depart,
          cabin: _selectedCabin,
          sort: _selectedSort,
          pax: _pax,
        ),
      ),
    );

    // If results are returned from the filter page, update state and re-fetch flights
    if (result != null && result is Map<String, String>) {
      setState(() {
        _to = result['to']!;
        _depart = result['depart']!;
        _selectedCabin = result['cabin']!;
        _selectedSort = result['sort']!;
        _pax =
            result['pax'] ?? '1'; // Ensure pax defaults to '1' if somehow null
      });
      _fetchFlights(); // Re-fetch flights with new filter criteria
    }
  }

  @override
  Widget build(BuildContext context) {
    final int paxCount =
        int.tryParse(_pax) ?? 1; // Parse pax count for total price calculation

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Arrival Flights',
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFAA0000),
                      ),
                    ) // Red loading indicator
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : _flights.isEmpty
                  ? const Center(
                      child: Text(
                        'No flights found for your criteria.',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _flights.length,
                      itemBuilder: (context, index) {
                        final flight = _flights[index];
                        final totalPrice =
                            (double.tryParse(flight.price.toString()) ?? 0.0) *
                            paxCount;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            // Use InkWell for a ripple effect on tap
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArrivalFlightDetailPage(
                                    flightDetail: flight.token,
                                    pax: paxCount.toString(),
                                    totalPrice: totalPrice.toStringAsFixed(
                                      2,
                                    ), // Pass formatted price
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        flight.airline,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              20, // Slightly smaller airline name (was 22)
                                          color: Color(
                                            0xFFAA0000,
                                          ), // Red airline name
                                        ),
                                      ),
                                      Text(
                                        '\$${totalPrice.toStringAsFixed(2)} (${paxCount} pax)', // Formatted total price with pax
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              18, // Slightly smaller price (was 20)
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                    color: Colors.grey,
                                    height: 1,
                                  ), // Visual separator
                                  const SizedBox(height: 8),

                                  // Departure Airport Row
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .flight_takeoff, // Flight takeoff icon
                                        size: 24,
                                        color: Color(0xFFAA0000), // Red icon
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${flight.from} (${_formatTimeOnly(flight.departTime)})', // Format time only
                                          style: const TextStyle(
                                            fontSize:
                                                16, // Smaller airport text (was 18)
                                            fontWeight:
                                                FontWeight.bold, // Keep bold
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Multiple arrow icons
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(
                                        5,
                                        (index) => const Icon(
                                          Icons.arrow_downward,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Arrival Airport Row
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.flight_land, // Flight land icon
                                        size: 24,
                                        color: Color(0xFFAA0000), // Red icon
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${flight.to} (${_formatTimeOnly(flight.arriveTime)})', // Format time only
                                          style: const TextStyle(
                                            fontSize:
                                                16, // Smaller airport text (was 18)
                                            fontWeight:
                                                FontWeight.bold, // Keep bold
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Date information - More prominent
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatFullDateTime(
                                        flight.departTime,
                                      ).split(',')[0],
                                      style: const TextStyle(
                                        fontSize:
                                            16, // Keep date font size as is
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ArrivalFlightDetailPage(
                                                  flightDetail: flight.token,
                                                  pax: paxCount.toString(),
                                                  totalPrice: totalPrice
                                                      .toStringAsFixed(2),
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFAA0000,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      child: const Text(
                                        'Book',
                                        style: TextStyle(
                                          fontSize: 16,
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
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: _openFilterPage,
          icon: const Icon(Icons.filter_list, color: Colors.white),
          label: const Text(
            'Filter',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFAA0000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
