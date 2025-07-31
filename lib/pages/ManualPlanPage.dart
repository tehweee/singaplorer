import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Required for date and currency formatting

// Placeholder for your GoogleMapData page
import 'GoogleMapPage.dart'; // Create this file

class ManualPlanPage extends StatefulWidget {
  @override
  _ManualPlanPageState createState() => _ManualPlanPageState();
}

class _ManualPlanPageState extends State<ManualPlanPage> {
  List<Map<String, dynamic>> itineraryDetails = [];
  List<dynamic> itineraryIDs = [];
  bool _isLoading = true;
  String? _errorMessage = '';

  // Define the new color constants
  static const Color primaryRed = Color(0xFF780000);
  static const Color accentRed = Color(
    0xFFB11204,
  ); // A slightly lighter red for accents

  // Base URL for the backend API
  static const String _baseUrl =
      'http://10.0.2.2:3000'; // Change to your real backend URL

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  // Fetches the user's travel plans from the backend
  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/manualPlan'));
      if (res.statusCode == 200) {
        List<dynamic> plans = jsonDecode(res.body);
        List<String> planIDs = [];
        List<Map<String, dynamic>> fetchedItineraries = [];
        print(fetchedItineraries);

        for (var plan in plans) {
          planIDs.add(plan['_id']);
          final arrive = await _fetchItem('arrive', plan['arriveSGId']);
          final depart = await _fetchItem('depart', plan['departSGId']);
          final hotel = await _fetchItem('hotel', plan['hotelId']);

          List<Map<String, dynamic>> attractions = [];
          // Ensure 'attractionId' is not null before iterating
          if (plan['attractionId'] != null) {
            for (var attrId in plan['attractionId']) {
              final attraction = await _fetchItem('attraction', attrId);
              if (attraction != null) attractions.add(attraction);
            }
          }

          fetchedItineraries.add({
            'arrive': arrive,
            'depart': depart,
            'hotel': hotel,
            'attractions': attractions,
          });
        }
        setState(() {
          itineraryDetails = fetchedItineraries;
          itineraryIDs = planIDs;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load plans: HTTP ${res.statusCode}';
        });
        throw Exception('Failed to load plans');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching plans: ${e.toString()}';
      });
      print('Error fetching plans: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetches a single item (arrival, departure, hotel, or attraction) by type and ID
  Future<Map<String, dynamic>?> _fetchItem(String type, String? id) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/$type/$id'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print('Failed to load $type $id: HTTP ${res.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching $type: $e');
      return null;
    }
  }

  // Helper to format date-time strings (e.g., 2025-07-25T03:10:00)
  String _formatDateTime(String dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      // Format to "Jul 25, 2025 03:10"
      return DateFormat('MMM d, yyyy HH:mm').format(dateTime);
    } catch (e) {
      print('Error parsing date-time "$dateTimeString": $e');
      return dateTimeString; // Return original if parsing fails
    }
  }

  // Helper to format date strings (e.g., 2025-07-20)
  String _formatDate(String dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      // Format to "Jul 20, 2025"
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      print('Error parsing date "$dateString": $e');
      return dateString; // Return original if parsing fails
    }
  }

  // Helper to format currency values, robustly handling strings or numbers
  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';

    double? numericAmount;
    if (amount is String) {
      numericAmount = double.tryParse(amount);
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    if (numericAmount == null) {
      print(
        'Warning: Could not parse amount "$amount" to a number for currency formatting.',
      );
      return '\$N/A'; // Fallback for unparseable amounts
    }

    try {
      final numberFormat = NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 2,
      );
      return numberFormat.format(numericAmount);
    } catch (e) {
      print('Error formatting currency with NumberFormat: $e');
      return '\$${numericAmount.toStringAsFixed(2)}'; // Fallback using toStringAsFixed
    }
  }

  void _deleteItinerary(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await http.delete(Uri.parse('$_baseUrl/api/deletePlan/$id'));
      if (res.statusCode == 200) {
        setState(() {
          _fetchPlans();
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Itineraries"),
        centerTitle: true,
        backgroundColor: primaryRed, // Changed color to primaryRed
        foregroundColor: Colors.white, // Text color for app bar
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryRed), // Changed color
                  SizedBox(height: 10),
                  Text('Loading itineraries...'),
                ],
              ),
            )
          : _errorMessage!.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: primaryRed, // Changed color
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: primaryRed, // Changed color
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _fetchPlans,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed, // Changed color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : itineraryDetails.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: primaryRed,
                      size: 60,
                    ), // Changed color
                    SizedBox(height: 20),
                    Text(
                      "It looks like you haven't planned any itineraries yet. Let's start planning your amazing trip!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: primaryRed,
                      ), // Changed color
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              // Added RefreshIndicator for pull-to-refresh
              onRefresh: _fetchPlans,
              child: ListView.builder(
                itemCount: itineraryDetails.length,
                itemBuilder: (context, index) {
                  final item = itineraryDetails[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 8, // Increased elevation for more depth
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // More rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20), // Increased padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Itinerary Title (Optional, but good for multiple itineraries)
                          if (itineraryDetails.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Itinerary #${index + 1}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: primaryRed, // Changed color
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteItinerary(itineraryIDs[index]),
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),

                          _buildSectionHeader("Returning", Icons.flight_land),
                          if (item['arrive'] != null) ...[
                            _buildDetailText(
                              "From:",
                              "${item['arrive']['fromCountry']} (${item['arrive']['fromAirport']})",
                            ),
                            _buildDetailText(
                              "Departure:",
                              _formatDateTime(item['arrive']['departureTime']),
                            ),
                            _buildDetailText(
                              "Arrival:",
                              _formatDateTime(item['arrive']['arrivalTime']),
                            ),
                            _buildDetailText(
                              "Cabin Class:",
                              item['arrive']['cabinClass'],
                            ),
                            _buildDetailText(
                              "Price per Pax:",
                              _formatCurrency(item['arrive']['pricePerPax']),
                            ),
                          ] else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "No arrival details available.",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),

                          _buildSectionHeader(
                            "Originating",
                            Icons.flight_takeoff,
                          ),
                          if (item['depart'] != null) ...[
                            _buildDetailText(
                              "To:",
                              "${item['depart']['toCountry']} (${item['depart']['toCityName']})",
                            ),
                            _buildDetailText(
                              "Departure:",
                              _formatDateTime(item['depart']['departureTime']),
                            ),
                            _buildDetailText(
                              "Arrival:",
                              _formatDateTime(item['depart']['arrivalTime']),
                            ),
                            _buildDetailText(
                              "Cabin Class:",
                              item['depart']['cabinClass'],
                            ),
                            _buildDetailText(
                              "Price per Pax:",
                              _formatCurrency(item['depart']['pricePerPax']),
                            ),
                          ] else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "No departure details available.",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),

                          _buildSectionHeader("Hotel", Icons.hotel),
                          if (item['hotel'] != null) ...[
                            _buildDetailText("Name:", item['hotel']['title']),
                            _buildDetailText(
                              "Address:",
                              item['hotel']['address'],
                            ),
                            _buildDetailText("City:", item['hotel']['city']),
                            _buildDetailText(
                              "Check-in:",
                              _formatDate(item['hotel']['arrivalDate']),
                            ),
                            _buildDetailText(
                              "Check-out:",
                              _formatDate(item['hotel']['departureDate']),
                            ),
                            _buildDetailText(
                              "Review Score:",
                              "${item['hotel']['reviewScore']} / ${item['hotel']['reviewCount']}",
                            ),
                            _buildDetailText(
                              "Total Price:",
                              _formatCurrency(item['hotel']['totalPrice']),
                            ),
                            _buildDetailText(
                              "Latitude:",
                              item['hotel']['latitude'],
                            ),
                            _buildDetailText(
                              "Longitude:",
                              item['hotel']['longitude'],
                            ),
                          ] else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "No hotel details available.",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader(
                                "Attractions",
                                Icons.attractions,
                              ),
                              IconButton(
                                onPressed: null,
                                icon: Icon(Icons.add),
                              ),
                            ],
                          ),
                          if (item['attractions'] != null &&
                              item['attractions'].isNotEmpty)
                            ...item['attractions'].map<Widget>(
                              (attr) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 12.0,
                                  left: 8.0,
                                ), // Increased bottom padding for separation
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ${attr['title']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            accentRed, // Changed color to accentRed
                                      ), // Darker, bolder title
                                    ),
                                    _buildIndentedDetailText(
                                      "Address:",
                                      attr['address'],
                                    ),
                                    _buildIndentedDetailText(
                                      "Booked Date:",
                                      _formatDateTime(attr['bookedDate']),
                                    ),
                                    _buildIndentedDetailText(
                                      "Price per Pax:",
                                      _formatCurrency(attr['pricePerPax']),
                                    ),
                                    _buildIndentedDetailText(
                                      "Description:",
                                      attr['description'],
                                      maxLines: 3,
                                    ),
                                    _buildIndentedDetailText(
                                      "Latitude:",
                                      attr['latitude'],
                                    ),
                                    _buildIndentedDetailText(
                                      "Longitude:",
                                      attr['longitude'],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Text(
                              "No attractions booked for this itinerary.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 20),

                          // New: Button to view on map
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GoogleMapData(itinerary: item),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map, color: Colors.white),
                              label: const Text(
                                'View on Map',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    accentRed, // Changed color to accentRed
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Reusable widget for section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: primaryRed, // Changed color to primaryRed
          ), // Larger, more prominent icon
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20, // Larger font size for headers
              color: primaryRed, // Changed color to primaryRed
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widget for detail texts with a bold label
  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty)
                  ? 'No data found'
                  : value, // Use 'N/A' if value is null
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widget for indented detail texts (for attractions) with a bold label
  Widget _buildIndentedDetailText(
    String label,
    String? value, {
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        bottom: 4.0,
      ), // Indent for attraction details
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty)
                  ? 'No data found'
                  : value, // Use 'N/A' if value is null
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              maxLines: maxLines,
              overflow: maxLines != null
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
