import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HotelDetailPage.dart';
import '../models/HotelModel.dart'; // Make sure this file contains the Hotel model

class HotelPage extends StatefulWidget {
  const HotelPage({Key? key}) : super(key: key);

  @override
  State<HotelPage> createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> {
  List<Hotel> _hotel = [];

  final _arrivalController = TextEditingController(text: '2025-07-12');
  final _departController = TextEditingController(text: '2025-07-13');
  final _minPriceController = TextEditingController(text: '0');
  final _maxPriceController = TextEditingController(text: '100');

  Future<void> _fetchHotels() async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/hotels'
      '?arrival_date=${_arrivalController.text}'
      '&departure_date=${_departController.text}'
      '&minPrice=${_minPriceController.text}'
      '&maxPrice=${_maxPriceController.text}',
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
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Hotels')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _arrivalController,
                decoration: InputDecoration(labelText: 'Arrival'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _departController,
                decoration: InputDecoration(labelText: 'Departure'),
              ),
            ),
          ]),
          TextField(
            controller: _minPriceController,
            decoration: InputDecoration(labelText: 'Min Price'),
          ),
          TextField(
            controller: _maxPriceController,
            decoration: InputDecoration(labelText: 'Max Price'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchHotels,
            child: Text('Search Hotels'),
          ),
          Expanded(
            child: _hotel.isEmpty
                ? Center(child: Text('No hotels found'))
                : ListView.builder(
                    itemCount: _hotel.length,
                    itemBuilder: (context, index) {
                      final hotel = _hotel[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${hotel.name} - ${hotel.priceGross}'),
                          subtitle: Text(
                            '${hotel.checkInDate} to ${hotel.checkOutDate}\n${hotel.checkInFrom} ➜ ${hotel.checkOutFrom}',
                          ),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            child: Text('Details'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HotelDetailPage(hotelID:hotel.hotelID.toString(),arrivalDate:hotel.checkInDate,departureDate:hotel.checkOutDate),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class HotelDetailsScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hotel Name: ${hotel.name}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Price: ${hotel.priceGross}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Check-in: ${hotel.checkInDate} at ${hotel.checkInFrom}'),
            Text('Check-out: ${hotel.checkOutDate} at ${hotel.checkOutFrom}'),
            SizedBox(height: 20),
            Text('Enjoy your stay!'),
          ],
        ),
      ),
    );
  }
}
