import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HotelDetailPage.dart'; // Ensure this is correctly imported
import '../models/HotelModel.dart'; // Ensure this file contains the Hotel model
import 'package:intl/intl.dart';
import 'HotelFilterPage.dart'; // Import the FilterPage

class HotelPage extends StatefulWidget {
  const HotelPage({Key? key}) : super(key: key);

  @override
  State<HotelPage> createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> {
  List<Hotel> _hotels = [];

  // Default filter values
  String _arrivalDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _departureDate = DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now().add(Duration(days: 5)));
  String _minPrice = '0';
  String _maxPrice = '5000';
  bool _isLoading = true;
  String? _error;

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
          _hotels = hotels.map((item) => Hotel.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load hotels');
      }
    } catch (e) {
      print('Exception: $e');
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
      appBar: AppBar(
        title: const Text('Book Hotel'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB11204), // Red color from your design
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFAA0000)),
            ) // Red loading indicator
          : _error != null
          ? Center(
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          : _hotels.isEmpty
          ? const Center(child: Text('No hotels found'))
          : ListView.builder(
              itemCount: _hotels.length,
              itemBuilder: (context, index) {
                final hotel = _hotels[index];
                final formattedPrice = hotel.priceGross.toStringAsFixed(2);
                final imageUrl = hotel.imageUrls.isNotEmpty
                    ? hotel.imageUrls[0]
                    : 'https://placehold.co/600x400/E0E0E0/000000?text=No+Image';

                // Determine if the hotel is a trusted partner (rating >= 9.0)
                final isTrustedPartner = hotel.reviewScore >= 9.0;

                return GestureDetector(
                  // Added GestureDetector for tapping
                  onTap: () {
                    // *** THIS IS THE CORRECTED PART ***
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelDetailPage(
                          hotelID: hotel.hotelID, // Pass the hotelID
                          arrivalDate:
                              _arrivalDate, // Pass the current arrival date
                          departureDate:
                              _departureDate, // Pass the current departure date
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hotel Image - Top
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
                          // Hotel Details - Below the image
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hotel Name
                                Text(
                                  hotel.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Star Rating
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
                                const SizedBox(height: 4),
                                // Review Score and Count
                                if (hotel.reviewScore > 0)
                                  Text(
                                    'Exceptional (${hotel.reviewScore.toStringAsFixed(1)}/10) - ${hotel.reviewCount} reviews',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Fast Service
                                const Text(
                                  'Fast Service Available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFB11204),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Trusted Partner with Mascot (Conditional)
                                if (isTrustedPartner)
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/mascot.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Trusted Partner',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                // Price per night - Aligned to bottom
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    '\$${formattedPrice} per night',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB11204),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilterPage,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filter'),
        backgroundColor: const Color(0xFFB11204),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
