import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ItineraryDateModel.dart'; // BookingDate class

class ItineraryBookingPage extends StatefulWidget {
  final String slug;
  const ItineraryBookingPage({super.key, required this.slug});

  @override
  State<ItineraryBookingPage> createState() => _ItineraryBookingPageState();
}

class _ItineraryBookingPageState extends State<ItineraryBookingPage> {
  List<BookingDate> _dates = [];
  final _dateController = TextEditingController(text: '2025-07-23');
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    final encodedSlug = Uri.encodeComponent(widget.slug);
    final encodedDate = Uri.encodeComponent(_dateController.text);

    final uri = Uri.parse(
      'http://10.0.2.2:3000/api/attraction/detail/avalibility'
      '?slug=$encodedSlug&date=$encodedDate',
    );

    try {
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dates = List<Map<String, dynamic>>.from(data['data'] ?? []);

        setState(() {
          _dates = dates.map((item) => BookingDate.fromJson(item)).toList();
          _selectedDate = null;
        });
      } else {
        throw Exception('Failed to load availability');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _selectDate(String date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _checkout() async {
    if (_selectedDate == null) return;

    // Debug print
    print('Sending slug: ${widget.slug}');
    print('Sending date: $_selectedDate');

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Checkout"),
        content: Text("Proceeding to checkout with:\n$_selectedDate"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    final uri = Uri.parse('http://10.0.2.2:3000/api/attraction/checkout');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slug': widget.slug, 'date': _selectedDate}),
      );

      print('Checkout response status: ${response.statusCode}');
      print('Checkout response body: ${response.body}');
    } catch (e) {
      print('Checkout error: $e');
    }
  }

  bool _isValidDate(String input) {
    try {
      final parsed = DateTime.parse(input);
      return input == parsed.toIso8601String().split('T').first;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Booking Date")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Enter date (yyyy-MM-dd)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              onSubmitted: (value) {
                if (_isValidDate(value)) {
                  _fetchFlights();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid date format")),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_isValidDate(_dateController.text)) {
                  _fetchFlights();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid date format")),
                  );
                }
              },
              child: const Text("Search Availability"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _dates.isEmpty
                  ? const Center(child: Text("No available dates"))
                  : ListView.builder(
                      itemCount: _dates.length,
                      itemBuilder: (context, index) {
                        final date = _dates[index].date;
                        return RadioListTile<String>(
                          title: Text(date),
                          value: date,
                          groupValue: _selectedDate,
                          onChanged: (value) => _selectDate(value!),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectedDate != null ? _checkout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Checkout", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
