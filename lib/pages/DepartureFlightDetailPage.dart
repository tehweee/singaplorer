import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/FlightDetailModel.dart'; // Ensure your FlightDetail class is here
import 'dart:math';

class DepartureFlightDetailPage extends StatefulWidget {
  final String flightDetail;

  const DepartureFlightDetailPage({super.key, required this.flightDetail});

  @override
  State<DepartureFlightDetailPage> createState() =>
      _DepartureFlightDetailPageState();
}

class _DepartureFlightDetailPageState extends State<DepartureFlightDetailPage> {
  List<FlightDetail> _flightDetail = [];

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    final encodedToken = Uri.encodeComponent(widget.flightDetail);

    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/flights/detail?token=$encodedToken',
    );

    try {
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _flightDetail = [FlightDetail.fromJson(data['data'])]; // wrap in list
        });
      } else {
        throw Exception('Failed to load flight detail');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flight Details')),
      body: _flightDetail.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _flightDetail.length,
                itemBuilder: (context, index) {
                  final flight = _flightDetail[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            'From:',
                            '${flight.departureAirport}, ${flight.departureCountry}',
                          ),
                          _infoRow(
                            'To:',
                            '${flight.arrivalAirport}, ${flight.arrivalCountry}',
                          ),
                          const SizedBox(height: 10),
                          _infoRow('Departure Time:', flight.departureTime),
                          _infoRow('Arrival Time:', flight.arrivalTime),
                          const SizedBox(height: 10),
                          _infoRow('Price:', '\$${flight.price}', isBold: true),
                          _infoRow(
                            'Cabin Class:',
                            '\$${flight.cabinClass}',
                            isBold: true,
                          ),

                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                _checkout(
                                  flight.departureCountry,
                                  flight.departureAirport,
                                  flight.departureTime,
                                  flight.arrivalTime,
                                  flight.price,
                                  flight.cabinClass,
                                );
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Booking Confirmed'),
                                    content: Text(
                                      'You have booked the flight with token: ${flight.token}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                textStyle: TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Book Officially'),
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

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout(
    country,
    airport,
    departTime,
    arrivalTime,
    price,
    cabin,
  ) async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/departure/flights/checkout',
    );

    try {
      String secretKey = generateSecretKey(16);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': widget.flightDetail,
          'fromCountry': country,
          'fromAirport': airport,
          'departureTime': departTime,
          'arrivalTime': arrivalTime,
          'pricePerPax': price,
          'cabinClass': cabin,
        }),
      );

      print('Checkout response status: ${response.statusCode}');
      print('Checkout response body: ${response.body}');
    } catch (e) {
      print('Checkout error: $e');
    }
  }

  String generateSecretKey(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (index) => characters[random.nextInt(characters.length)],
    ).join();
  }
}
