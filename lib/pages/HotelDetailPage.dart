import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  // CORRECTED: This must be a single HotelDetail object, not a List.
  HotelDetail? _hotelDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/hotels/detail?hotel_id=${widget.hotelID}&arrival_date=${widget.arrivalDate}&departure_date=${widget.departureDate}',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // This 'result' is the single Map<String, dynamic> from your Node.js API's 'data' key.
        final result = data['data'];

        setState(() {
          if (result != null && result is Map<String, dynamic>) {
            // CORRECTED: Directly parse the map into the single _hotelDetail object.
            _hotelDetail = HotelDetail.fromJson(result);
          } else {
            // Handle cases where 'data' might be null or not a map
            _error =
                'Invalid data format or no hotel details found in response.';
          }
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load details: Server responded with status ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load details: $e';
        _isLoading = false;
      });
      print('Error fetching hotel details: $e'); // Log error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel Details"),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            )
          : _hotelDetail ==
                null // Check if the single object is null after loading
          ? const Center(child: Text("No hotel details found."))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name and Address Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hotelDetail!.name, // Access properties directly
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
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${_hotelDetail!.address}, ${_hotelDetail!.city}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Image Carousel
                  _hotelDetail!.hotelPhotos.isNotEmpty
                      ? SizedBox(
                          height: 250,
                          child: PageView.builder(
                            itemCount: _hotelDetail!.hotelPhotos.length,
                            itemBuilder: (context, index) {
                              final imageUrl = _hotelDetail!.hotelPhotos[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
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
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              'No images available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Details Grid Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Check-in Date:',
                          _hotelDetail!.arrivalDate,
                        ),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Check-out Date:',
                          _hotelDetail!.departureDate,
                        ),
                        _buildDetailRow(
                          Icons.attach_money,
                          'Total Price:',
                          '${_hotelDetail!.totalPrice.toStringAsFixed(2)} ${_hotelDetail!.currency}',
                          isPrice: true,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Book Now Button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
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
                                // Show success dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Booking Confirmed! 🎉',
                                      ),
                                      content: const Text(
                                        'Your hotel booking has been successfully processed.',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(); // Dismiss the dialog
                                            Navigator.pushReplacement(
                                              // Use pushReplacement to prevent going back to HotelDetailPage
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ItineraryPage(),
                                              ),
                                            );
                                          },
                                          child: const Text('Go to Itinerary'),
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
                            backgroundColor: Colors.deepPurpleAccent,
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // New helper widget to build consistent detail rows (as was suggested before)
  Widget _buildDetailRow(
    IconData icon,
    String label,
    dynamic value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
              color: isPrice ? Colors.green[700] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
