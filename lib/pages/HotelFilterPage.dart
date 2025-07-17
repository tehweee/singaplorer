import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class HotelFilterPage extends StatefulWidget {
  final String initialArrivalDate;
  final String initialDepartureDate;
  final String initialMinPrice;
  final String initialMaxPrice;

  const HotelFilterPage({
    Key? key,
    required this.initialArrivalDate,
    required this.initialDepartureDate,
    required this.initialMinPrice,
    required this.initialMaxPrice,
  }) : super(key: key);

  @override
  State<HotelFilterPage> createState() => _HotelFilterPageState();
}

class _HotelFilterPageState extends State<HotelFilterPage> {
  DateTime? _selectedArrivalDate;
  DateTime? _selectedDepartureDate;
  RangeValues _selectedPriceRange = const RangeValues(
    0,
    10000,
  ); // Default range for slider

  @override
  void initState() {
    super.initState();
    _selectedArrivalDate = DateTime.tryParse(widget.initialArrivalDate);
    _selectedDepartureDate = DateTime.tryParse(widget.initialDepartureDate);

    // Parse initial min/max prices for the slider, defaulting if invalid
    double initialMin = double.tryParse(widget.initialMinPrice) ?? 0;
    double initialMax = double.tryParse(widget.initialMaxPrice) ?? 10000;
    _selectedPriceRange = RangeValues(
      initialMin.clamp(0, 10000),
      initialMax.clamp(0, 10000),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDateRange:
          (_selectedArrivalDate != null && _selectedDepartureDate != null)
          ? DateTimeRange(
              start: _selectedArrivalDate!,
              end: _selectedDepartureDate!,
            )
          : null,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 2),
      ), // Allow 2 years from now
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Your accent color
              onPrimary: Colors.white, // Text color on primary
              surface: Colors.white, // Surface color of the dialog
              onSurface: Colors.black, // Text color on surface
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedArrivalDate = picked.start;
        _selectedDepartureDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Hotels')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Arrival Date'),
              subtitle: Text(
                _selectedArrivalDate == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedArrivalDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateRange(context),
            ),
            ListTile(
              title: const Text('Departure Date'),
              subtitle: Text(
                _selectedDepartureDate == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedDepartureDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateRange(context),
            ),
            const SizedBox(height: 20),
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RangeSlider(
              values: _selectedPriceRange,
              min: 0,
              max: 10000,
              divisions: 100, // 100 divisions for steps of 100 (10000 / 100)
              labels: RangeLabels(
                _selectedPriceRange.start.round().toString(),
                _selectedPriceRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _selectedPriceRange = values;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min: \$${_selectedPriceRange.start.round()}'),
                  Text('Max: \$${_selectedPriceRange.end.round()}'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'arrivalDate': _selectedArrivalDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedArrivalDate!)
                        : '',
                    'departureDate': _selectedDepartureDate != null
                        ? DateFormat(
                            'yyyy-MM-dd',
                          ).format(_selectedDepartureDate!)
                        : '',
                    'minPrice': _selectedPriceRange.start.round().toString(),
                    'maxPrice': _selectedPriceRange.end.round().toString(),
                  });
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
