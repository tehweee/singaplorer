import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ItineraryDetailPage.dart';
import '../models/ItineraryModel.dart'; // Make sure your model.dart file is correct


class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<Itinerary> _attractions = [];  


  Future<void> _fetchFlights() async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/attraction'
    );

    try {
      final response = await http.get(uri);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // DEBUGGING

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attractions = List<Map<String, dynamic>>.from(data['data'] ?? []);

        setState(() {
          _attractions = attractions.map((item) => Itinerary.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load flights');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Flights')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(children: [
            
          ]),
          
          Row(
            children: [
              
              
            ],
          ),

Expanded(
  child: _attractions.isEmpty
      ? Center(child: Text('No attraction found'))
      : ListView.builder(
          itemCount: _attractions.length,
          itemBuilder: (context, index) {
            final attraction = _attractions[index];
            return ListTile(
              title: Text('${attraction.name} - ${attraction.price}'),
              subtitle: Text(
                '${attraction.slug} \n${attraction.shortDescription}',
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItineraryDetailPage(attraction: attraction.slug),
                  ),
                );
              },
            );
          },
        ),
),

        ]),
      ),
    );
  }
}


