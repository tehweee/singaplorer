import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ItineraryDetailPage.dart'; // Make sure this file exists for navigation
import '../models/ItineraryModel.dart'; // Your Itinerary model
import 'ArrivalFlightPage.dart'; // <--- ADD THIS IMPORT for your flight page

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<Itinerary> _attractions = [];
  bool _isLoading = true; // Add loading state
  String? _error; // Add error state
  Itinerary? _selectedAttraction; // New: To hold the selected attraction

  Future<void> _fetchAttractions() async {
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
    _fetchAttractions();
  }

  @override
  Widget build(BuildContext context) {
    // Define the new color
    const Color primaryRed = Color(0xFF780000);
    const Color accentRed = Color(
      0xFFB11204,
    ); // A slightly lighter red for contrast/accents

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attractions in Singapore'),
        backgroundColor: primaryRed, // Changed color
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryRed),
            ) // Changed color
          : _error != null
          ? Center(
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : _attractions.isEmpty
          ? const Center(child: Text('No attractions found.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: _attractions.length,
                    itemBuilder: (context, index) {
                      final attraction = _attractions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          // New: Add border to indicate selection
                          side: _selectedAttraction == attraction
                              ? const BorderSide(
                                  color: primaryRed,
                                  width: 2.0,
                                ) // Changed color
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          // New: Set selected attraction on tap
                          onTap: () {
                            setState(() {
                              _selectedAttraction = attraction;
                            });
                            // Navigator.push is removed here to prevent immediate navigation
                            // when selecting. The button below will handle navigation.
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15.0),
                                ),
                                child: Image.network(
                                  attraction.image.isNotEmpty
                                      ? attraction.image
                                      : 'https://via.placeholder.com/400x200?text=No+Image+Available',
                                  height: 200,
                                  width: double.infinity,
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
                                    Text(
                                      attraction.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: primaryRed, // Changed color
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
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
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${attraction.price} SGD',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .green, // Keep green for price or change to another suitable color if desired
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        // New: Navigate to detail page on View Details button press
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
                                              accentRed, // Changed color (using accent red for "View Details")
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      // The button is now enabled because onPressed is not null
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArrivalFlightPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Go to Book Flight',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
