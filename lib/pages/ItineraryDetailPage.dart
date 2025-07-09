import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ItineraryBookingPage.dart';
import '../models/ItineraryDetailModel.dart'; // Contains DetailPlan and Review

class ItineraryDetailPage extends StatefulWidget {
  final String attraction;

  const ItineraryDetailPage({required this.attraction, super.key});

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  List<DetailItinerary> _details = [];
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
          if (result is List) {
            _details = result.map((item) => DetailItinerary.fromJson(item)).toList();
          } else if (result is Map<String, dynamic>) {
            _details = [DetailItinerary.fromJson(result)];
          } else {
            _details = [];
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load details: $e';
        _isLoading = false;
      });
    }
  }

  void _goToBookingPage(DetailItinerary detail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryBookingPage(slug:widget.attraction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attraction Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _details.isEmpty
                  ? const Center(child: Text('No details found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _details.length,
                      itemBuilder: (context, index) {
                        final detail = _details[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${detail.address}, ${detail.city}, ${detail.country}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '💵 Price: ${detail.price}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '📄 Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(detail.description),
                                const SizedBox(height: 8),
                                const Text(
                                  '⭐ Reviews',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('Total: ${detail.reviewTotal}'),
                                Text('Average Rating: ${detail.reviewStats}'),
                                const SizedBox(height: 12),
                                ...detail.reviews.isEmpty
                                    ? [const Text('No individual reviews available.')]
                                    : detail.reviews.map((review) {
                                        return Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '⭐ ${review.numericRating}/5',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                review.content?.isNotEmpty == true
                                                    ? review.content!
                                                    : 'No comment provided.',
                                              ),
                                              if (review.userName != null)
                                                Text(
                                                  '— ${review.userName!}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () => _goToBookingPage(detail),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Book Now',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
