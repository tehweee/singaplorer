import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ItineraryBookingPage.dart';
import '../models/ItineraryDetailModel.dart';

class ItineraryDetailPage extends StatefulWidget {
  final String attraction;

  const ItineraryDetailPage({required this.attraction, super.key});

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  DetailItinerary? _detail;
  bool _isLoading = true;
  String? _error;

  // Define the new color
  static const Color primaryRed = Color(0xFF780000); // Main theme color

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/attraction/detail?slug=${widget.attraction}',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['data'];

        setState(() {
          if (result != null && result is Map<String, dynamic>) {
            _detail = DetailItinerary.fromJson(result);
          } else {
            _error = 'Invalid data format or no details found.';
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load details: $e';
        _isLoading = false;
      });
      print('Error fetching attraction details: $e');
    }
  }

  void _goToBookingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryBookingPage(
          slug: widget.attraction,
          price: _detail!.price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_detail?.name ?? 'Attraction Details'),
        foregroundColor: Colors.white,
        backgroundColor: primaryRed, // Changed color
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryRed,
              ), // Changed color
            )
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
          : _detail == null
          ? const Center(child: Text('No details found for this attraction.'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detail!.photos.isNotEmpty
                      ? SizedBox(
                          height: 250,
                          child: PageView.builder(
                            itemCount: _detail!.photos.length,
                            itemBuilder: (context, index) {
                              final imageUrl = _detail!.photos[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _detail!.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${_detail!.address}, ${_detail!.city}, ${_detail!.country}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Redesigned Price, Rating, Reviews section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price
                            Text(
                              'Price: \$${_detail!.price.toStringAsFixed(2)} SGD',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .green
                                    .shade700, // Kept green for price, but darker shade
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ), // Spacing between elements
                            // Rating
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Colors
                                      .amber
                                      .shade700, // Darker amber for elegance
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_detail!.reviewStats.toStringAsFixed(1)}/5',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors
                                        .black87, // Neutral color for text
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10), // Spacing
                            // Reviews Total
                            Row(
                              children: [
                                Icon(
                                  Icons.reviews,
                                  size: 20,
                                  color: Colors
                                      .grey[700], // Neutral grey for reviews icon
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_detail!.reviewTotal} Reviews',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors
                                        .grey[700], // Neutral grey for text
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          _detail!.description,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Customer Reviews',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        _detail!.reviews.isEmpty
                            ? const Text('No individual reviews available yet.')
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _detail!.reviews.length,
                                itemBuilder: (context, idx) {
                                  final review = _detail!.reviews[idx];
                                  final formattedDate = review.epochMs != null
                                      ? DateTime.fromMillisecondsSinceEpoch(
                                          review.epochMs!,
                                        )
                                      : null;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 2,
                                    color: Colors.grey[50],
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage:
                                                    review.userAvatar != null
                                                    ? NetworkImage(
                                                        review.userAvatar!,
                                                      )
                                                    : null,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: review.userAvatar == null
                                                    ? const Icon(
                                                        Icons.person,
                                                        color: Colors.grey,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      review.userName ??
                                                          'Anonymous',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (review.userCountry !=
                                                        null)
                                                      Text(
                                                        review.userCountry!,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    if (formattedDate != null)
                                                      Text(
                                                        '${formattedDate.toLocal()}'
                                                            .split(' ')[0],
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    if (review.language != null)
                                                      Text(
                                                        'Language: ${review.language}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${review.numericRating}/5',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            review.content?.isNotEmpty == true
                                                ? review.content!
                                                : 'No comment provided.',
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (review
                                              .travelPartnerTypes
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: review
                                                  .travelPartnerTypes
                                                  .map(
                                                    (type) => Chip(
                                                      label: Text(type),
                                                      backgroundColor: Colors
                                                          .grey[200], // Changed chip background
                                                      labelStyle: TextStyle(
                                                        color: Colors
                                                            .grey[700], // Changed chip text color
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToBookingPage,
        icon: const Icon(Icons.confirmation_num_rounded),
        label: const Text(
          'Book Your Itinerary Now',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor:
            primaryRed, // Changed color from deepOrangeAccent to primaryRed
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // The _buildInfoChip widget was removed as its functionality is now implemented directly
  // within the build method for a more custom and integrated layout of price, rating, and reviews.
}
