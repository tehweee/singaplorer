import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HotelDetailModel.dart';

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
  List<HotelDetail> _hotel = [];
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
        final result = data['data'];

        setState(() {
          if (result is List) {
            _hotel = result.map((item) => HotelDetail.fromJson(item)).toList();
          } else if (result is Map<String, dynamic>) {
            _hotel = [HotelDetail.fromJson(result)];
          } else {
            _hotel = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _hotel.isEmpty
                  ? const Center(child: Text("No hotel details found."))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: _hotel.length,
                        itemBuilder: (context, index) {
                          final hotel = _hotel[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Expanded(child: Text("${hotel.address}, ${hotel.city}")),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoTile("Check-In", hotel.arrivalDate),
                                      _buildInfoTile("Check-Out", hotel.departureDate),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoTile("Price", "SGD ${hotel.totalPrice}"),
                                      _buildInfoTile("Rating", "${hotel.reviewScore}/10"),
                                      _buildInfoTile("Reviews", hotel.reviewCount),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                          final uri = Uri.parse('http://10.0.2.2:3000/api/hotels/checkout');
                                          try {
                                            final response = http.post(
                                              uri,
                                              headers: {'Content-Type': 'application/json'},
                                              body: jsonEncode({
                                                'hotel_id': widget.hotelID,
                                                'arrival_date':widget.arrivalDate,
                                                'departure_date':widget.departureDate
                                              }),
                                            );
                                          } catch (e) {
                                            print('Checkout error: $e');
                                          }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Book Now",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}


