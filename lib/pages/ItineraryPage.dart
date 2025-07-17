import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ItineraryDetailPage.dart'; // Make sure this file exists for navigation
import '../models/ItineraryModel.dart'; // Your Itinerary model

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<Itinerary> _attractions = [];
  bool _isLoading = true; // Add loading state
  String? _error; // Add error state

  Future<void> _fetchAttractions() async {
    // Renamed from _fetchFlights for clarity
    final uri = Uri.parse('http://10.0.2.2:3000/api/attraction');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attractionsData = List<Map<String, dynamic>>.from(
          data['data'] ?? [],
        );

        setState(() {
          _attractions = attractionsData
              .map((item) => Itinerary.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load attractions: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load attractions: $e';
        _isLoading = false;
      });
      print('Exception fetching attractions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAttractions(); // Call the renamed fetch method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attractions in Singapore'), // More descriptive title
        backgroundColor: Colors.deepPurple, // Example AppBar color
        foregroundColor: Colors.white, // Text color
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Show loading spinner
          : _error != null
          ? Center(
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ) // Show error message
          : _attractions.isEmpty
          ? const Center(child: Text('No attractions found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _attractions.length,
              itemBuilder: (context, index) {
                final attraction = _attractions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  elevation: 6, // Add shadow for depth
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15.0,
                    ), // Rounded corners
                  ),
                  child: InkWell(
                    // Make the entire card tappable
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ItineraryDetailPage(attraction: attraction.slug),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large Image Display
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15.0),
                          ),
                          child: Image.network(
                            attraction.image.isNotEmpty
                                ? attraction.image
                                : 'https://via.placeholder.com/400x200?text=No+Image+Available', // Placeholder
                            height: 200, // Fixed height for images
                            width: double.infinity, // Take full width
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Attraction Name (Large and Bold)
                              Text(
                                attraction.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .deepPurple, // Primary color for name
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Short Description (Clear, maybe slightly lighter)
                              Text(
                                attraction.shortDescription,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              // Price (Prominent)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${attraction.price} SGD', // Assuming price is a string from API now
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green, // Highlight price
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // View Details Button
                              SizedBox(
                                width: double.infinity, // Full width button
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ItineraryDetailPage(
                                              attraction: attraction.slug,
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.deepPurpleAccent, // Button color
                                    foregroundColor:
                                        Colors.white, // Button text color
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'View Details',
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
