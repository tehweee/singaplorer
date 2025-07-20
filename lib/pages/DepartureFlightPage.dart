import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'DepartureFlightDetailPage.dart';
import 'DepartureFlightFilter.dart';
import '../models/FlightModel.dart';

class DepartureFlightPage extends StatefulWidget {
  const DepartureFlightPage({super.key});

  @override
  State<DepartureFlightPage> createState() => _DepartureFlightPageState();
}

class _DepartureFlightPageState extends State<DepartureFlightPage> {
  List<Flight> _flights = [];

  String _from = 'LHR.AIRPORT';
  String _to = 'SIN.AIRPORT';
  String _depart = '2025-07-25';
  String _selectedCabin = 'ECONOMY';
  String _selectedSort = 'BEST';
  String _pax = '1';

  bool _isLoading = false;
  String? _error;

  Future<void> _fetchFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/flights'
      '?from=$_from'
      '&to=$_to'
      '&depart=$_depart'
      '&cabinClass=$_selectedCabin'
      '&sort=$_selectedSort',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final flights = List<Map<String, dynamic>>.from(data['data'] ?? []);
        setState(() {
          _flights = flights.map((item) => Flight.fromJson(item)).toList();
        });
      } else {
        setState(() {
          _error =
              'Failed to load flights. Status code: ${response.statusCode}';
          _flights = [];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading flights: $e';
        _flights = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  void _openFilterPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterPage(
          to: _to,
          depart: _depart,
          cabin: _selectedCabin,
          sort: _selectedSort,
          pax: _pax,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _to = result['to']!;
        _depart = result['depart']!;
        _selectedCabin = result['cabin']!;
        _selectedSort = result['sort']!;
        _pax = result['pax'] ?? '1';
      });
      _fetchFlights();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int paxCount = int.tryParse(_pax) ?? 1;

    return Scaffold(
      appBar: AppBar(title: Text('Search Departure Flights')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _flights.isEmpty
            ? Center(child: Text('No flights found'))
            : ListView.builder(
                itemCount: _flights.length,
                itemBuilder: (context, index) {
                  final flight = _flights[index];
                  final totalPrice =
                      (double.tryParse(flight.price.toString()) ?? 0.0) *
                      paxCount;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${flight.airline} - \$${totalPrice.toStringAsFixed(2)} ($paxCount pax)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                                    builder: (_) => DepartureFlightDetailPage(
                                      flightDetail: flight.token,
                                      pax: paxCount.toString(),
                                      totalPrice: totalPrice.toString(),
                                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilterPage,
        icon: Icon(Icons.filter_list),
        label: Text('Filter'),
      ),
    );
  }
}
