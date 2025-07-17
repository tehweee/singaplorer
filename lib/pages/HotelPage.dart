import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HotelDetailPage.dart';
import '../models/HotelModel.dart'; // Ensure this file contains the Hotel model
import 'HotelFilterPage.dart'; // Import the FilterPage

class HotelPage extends StatefulWidget {
  const HotelPage({Key? key}) : super(key: key);

  @override
  State<HotelPage> createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> {
  List<Hotel> _hotel = [];

  // Default filter values
  String _arrivalDate = '2025-07-20';
  String _departureDate = '2025-07-21';
  String _minPrice = '0';
  String _maxPrice = '100';

  @override
  void initState() {
    super.initState();
    _fetchHotels(); // Fetch hotels with default values on initial load
  }

  Future<void> _fetchHotels() async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/hotels'
      '?arrival_date=$_arrivalDate'
      '&departure_date=$_departureDate'
      '&minPrice=$_minPrice'
      '&maxPrice=$_maxPrice',
    );

    try {
      final response = await http.get(uri);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hotels = List<Map<String, dynamic>>.from(data['data'] ?? []);

        setState(() {
          _hotel = hotels.map((item) => Hotel.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load hotels');
      }
    } catch (e) {
      print('Exception: $e');
      // Optionally show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load hotels. Please try again later.'),
        ),
      );
    }
  }

  void _openFilterPage() async {
    final Map<String, String>? filters = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelFilterPage(
          initialArrivalDate: _arrivalDate,
          initialDepartureDate: _departureDate,
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
        ),
      ),
    );

    if (filters != null) {
      setState(() {
        _arrivalDate = filters['arrivalDate'] ?? _arrivalDate;
        _departureDate = filters['departureDate'] ?? _departureDate;
        _minPrice = filters['minPrice'] ?? _minPrice;
        _maxPrice = filters['maxPrice'] ?? _maxPrice;
      });
      _fetchHotels(); // Fetch hotels with new filters
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Hotels')),
      body: _hotel.isEmpty
          ? const Center(child: Text('No hotels found'))
          : ListView.builder(
              itemCount: _hotel.length,
              itemBuilder: (context, index) {
                final hotel = _hotel[index];
                final formattedPrice = hotel.priceGross.toStringAsFixed(2);
                final imageUrl = hotel.imageUrls.isNotEmpty
                    ? hotel.imageUrls[0]
                    : 'https://placehold.co/600x400/E0E0E0/000000?text=No+Image'; // Placeholder if no image

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.network(
                          imageUrl,
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
                                  size: 50,
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
                            // Hotel Name
                            Text(
                              hotel.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Price
                            Text(
                              'Price: \$$formattedPrice ${hotel.priceCurrency}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Check-in/Check-out Dates
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${hotel.checkInDate} to ${hotel.checkOutDate}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Check-in/Check-out Times
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Check-in: ${hotel.checkInFrom} | Check-out: ${hotel.checkOutFrom}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Star Rating (if available)
                            if (hotel.starRating > 0)
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < hotel.starRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                            const SizedBox(height: 8),
                            // Review Score and Count
                            if (hotel.reviewScore > 0)
                              Text(
                                '${hotel.reviewText} (${hotel.reviewScore.toStringAsFixed(1)}/10) - ${hotel.reviewCount} reviews',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Details Button at the bottom
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor, // Use app's primary color
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HotelDetailPage(
                                    hotelID: hotel.hotelID.toString(),
                                    arrivalDate: hotel.checkInDate,
                                    departureDate: hotel.checkOutDate,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilterPage,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filter'),
      ),
    );
  }
}
