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
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
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
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildInfoChip(
                              Icons.attach_money,
                              'Price: \$${_detail!.price.toStringAsFixed(2)}',
                              Colors.green[700]!,
                            ),
                            _buildInfoChip(
                              Icons.star,
                              'Rating: ${_detail!.reviewStats.toStringAsFixed(1)}/5',
                              Colors.amber[700]!,
                            ),
                            _buildInfoChip(
                              Icons.reviews,
                              '${_detail!.reviewTotal} Reviews',
                              Colors.blue[700]!,
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
                                                      backgroundColor:
                                                          Colors.purple[50],
                                                      labelStyle:
                                                          const TextStyle(
                                                            color: Colors
                                                                .deepPurple,
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
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
