import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import '../models/HotelDetailModel.dart'; // Ensure this file exists and matches your model
import 'ItineraryPage.dart'; // Import your ItineraryPage

class HotelDetailPage extends StatefulWidget {
  final String hotelID;
  final String arrivalDate;
  final String departureDate;

  const HotelDetailPage({
    required this.hotelID,
    required this.arrivalDate,
    required this.departureDate,
    super.key,
  });

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  HotelDetail? _hotelDetail;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0; // For tracking the current image in carousel

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Ensure dates are correctly formatted if your API expects specific formats
    // Example: 2025-07-25
    final String formattedArrivalDate = widget.arrivalDate;
    final String formattedDepartureDate = widget.departureDate;

    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/hotels/detail?hotel_id=${widget.hotelID}&arrival_date=$formattedArrivalDate&departure_date=$formattedDepartureDate',
    );

    try {
      final response = await http.get(uri);
      print('Hotel Detail API Response Status: ${response.statusCode}');
      print('Hotel Detail API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['data'];

        setState(() {
          if (result != null && result is Map<String, dynamic>) {
            _hotelDetail = HotelDetail.fromJson(result);
            _isLoading = false;
          } else {
            _error =
                'Invalid data format or no hotel details found in response.';
            _isLoading = false;
          }
        });
      } else {
        setState(() {
          _error =
              'Failed to load details: Server responded with status ${response.statusCode}';
          _isLoading = false;
        });
        print(
          'Failed to load hotel details. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
      print('Error fetching hotel details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hotelDetail?.name ?? 'Hotel Details'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB11204), // Red brand color
        foregroundColor: Colors.white, // White text
        elevation: 0, // No shadow for a cleaner look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFB11204)),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB11204),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _hotelDetail == null
          ? const Center(
              child: Text(
                "No hotel details found.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel Section
                  Stack(
                    children: [
                      SizedBox(
                        height: 280, // Increased height for better visual
                        child: PageView.builder(
                          itemCount: _hotelDetail!.hotelPhotos.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final imageUrl = _hotelDetail!.hotelPhotos[index];
                            return Hero(
                              // Add Hero animation for smooth transition
                              tag:
                                  'hotelImage_${widget.hotelID}_$index', // Unique tag for each image
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  0,
                                ), // No border radius for full width image
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Image Indicator (dots)
                    ],
                  ),
                  // Hotel Name and Address Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hotelDetail!.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Color(0xFFB11204), // Red for icon
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${_hotelDetail!.address}, ${_hotelDetail!.city}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Booking Details Section
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB11204), // Red for section title
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Check-in Date:',
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(DateTime.parse(_hotelDetail!.arrivalDate)),
                        ),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Check-out Date:',
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(DateTime.parse(_hotelDetail!.departureDate)),
                        ),
                        _buildDetailRow(
                          Icons.star,
                          'Rating:',
                          '${_hotelDetail!.reviewScore.toStringAsFixed(1)}/10',
                        ),
                        _buildDetailRow(
                          Icons.rate_review,
                          'Reviews:',
                          '${_hotelDetail!.reviewCount}',
                        ),
                        const SizedBox(height: 16),

                        // Description Section
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _hotelDetail == null || _isLoading || _error != null
          ? null // Hide bottom bar if no hotel details or loading/error
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Price:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        '${_hotelDetail!.totalPrice.toStringAsFixed(2)} ${_hotelDetail!.currency}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB11204), // Red price
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50, // Fixed height for the button
                    child: ElevatedButton(
                      onPressed: () async {
                        final checkoutUri = Uri.parse(
                          'http://10.0.2.2:3000/api/hotels/checkout',
                        );
                        try {
                          final response = await http.post(
                            checkoutUri,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'hotel_id': widget.hotelID,
                              'arrival_date': widget.arrivalDate,
                              'departure_date': widget.departureDate,
                            }),
                          );

                          if (response.statusCode == 200) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Booking Confirmed! 🎉'),
                                  content: const Text(
                                    'Your hotel booking has been successfully processed.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ItineraryPage(), // Ensure ItineraryPage is a const widget or remove const
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Go to Itinerary',
                                        style: TextStyle(
                                          color: Color(0xFFB11204),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Booking failed: ${response.statusCode} - ${response.body}',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error during checkout: $e'),
                            ),
                          );
                          print('Checkout error: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB11204), // Red button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Book Now",
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
    );
  }

  // Helper widget to build consistent detail rows
  Widget _buildDetailRow(
    IconData icon,
    String label,
    dynamic value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // More vertical spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: const Color(0xFFB11204)), // Red icon
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Expanded(
            // Use Expanded to prevent overflow for long values
            child: Text(
              value.toString(),
              textAlign: TextAlign.right, // Align value to the right
              style: TextStyle(
                fontSize: 16,
                fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                color: isPrice
                    ? const Color(0xFFB11204)
                    : Colors.black, // Red for price
              ),
            ),
          ),
        ],
      ),
    );
  }
}
