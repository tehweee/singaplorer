import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'DepartureFlightDetailPage.dart';
import '../models/FlightModel.dart';

class DepartureFlightPage extends StatefulWidget {
  const DepartureFlightPage({super.key});

  @override
  State<DepartureFlightPage> createState() => _DepartureFlightPageState();
}

class _DepartureFlightPageState extends State<DepartureFlightPage> {
  List<Flight> _flights = [];

  final _fromController = TextEditingController(text: 'SIN.AIRPORT');
  final _toController = TextEditingController(text: 'LHR.AIRPORT');
  final _departController = TextEditingController(text: '2025-06-25');

  String _selectedCabin = 'ECONOMY';
  String _selectedSort = 'BEST';

  final List<String> _cabinOptions = [
    'ECONOMY',
    'PREMIUM_ECONOMY',
    'BUSINESS',
    'FIRST'
  ];

  final List<String> _sortOptions = ['BEST', 'CHEAPEST', 'FASTEST'];

  Future<void> _fetchFlights() async {
    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/flights'
      '?from=${_fromController.text}'
      '&to=${_toController.text}'
      '&depart=${_departController.text}'
      '&cabinClass=$_selectedCabin'
      '&sort=$_selectedSort',
    );

    try {
      final response = await http.get(uri);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // DEBUGGING

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final flights = List<Map<String, dynamic>>.from(data['data'] ?? []);

        setState(() {
          _flights = flights.map((item) => Flight.fromJson(item)).toList();
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
            Expanded(
              child: TextField(
                controller: _toController,
                decoration:
                    InputDecoration(labelText: 'To (e.g. LHR.AIRPORT)'),
              ),
            ),
            SizedBox(width: 10),
          ]),
          TextField(
            controller: _departController,
            decoration: InputDecoration(labelText: 'Departure (YYYY-MM-DD)'),
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCabin,
                  items: _cabinOptions
                      .map((cabin) =>
                          DropdownMenuItem(value: cabin, child: Text(cabin)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCabin = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Cabin Class'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSort,
                  items: _sortOptions
                      .map((sort) =>
                          DropdownMenuItem(value: sort, child: Text(sort)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Sort By'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchFlights,
            child: Text('Search Flights'),
          ),
          Expanded(
            child: _flights.isEmpty
                ? Center(child: Text('No flights found'))
                : ListView.builder(
  itemCount: _flights.length,
  itemBuilder: (context, index) {
    final flight = _flights[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${flight.airline} - \$${flight.price}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('${flight.from} → ${flight.to}'),
            Text('${flight.departTime} ➜ ${flight.arriveTime}'),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepartureFlightDetailPage(flightDetail: flight.token),
                  ),
                );
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Flight Booked!'),
                      content: Text(
                          'You booked a return flight with ${flight.airline} from ${flight.from} to ${flight.to}.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Book'),
              ),
            ),
          ],
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