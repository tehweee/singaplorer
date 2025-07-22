import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart'; // Import SfDateRangePicker

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
    // Parse initial dates
    _selectedArrivalDate = DateTime.tryParse(widget.initialArrivalDate);
    _selectedDepartureDate = DateTime.tryParse(widget.initialDepartureDate);

    // Ensure initialArrivalDate is not before today
    if (_selectedArrivalDate != null &&
        _selectedArrivalDate!.isBefore(DateTime.now())) {
      _selectedArrivalDate = DateTime.now();
    }
    // Ensure initialDepartureDate is not before today or initialArrivalDate
    if (_selectedDepartureDate != null &&
        _selectedDepartureDate!.isBefore(DateTime.now())) {
      _selectedDepartureDate = DateTime.now().add(
        const Duration(days: 1),
      ); // Default to tomorrow
    }
    if (_selectedArrivalDate != null &&
        _selectedDepartureDate != null &&
        _selectedDepartureDate!.isBefore(_selectedArrivalDate!)) {
      _selectedDepartureDate = _selectedArrivalDate!.add(
        const Duration(days: 1),
      ); // Default to day after arrival
    }

    // Parse initial min/max prices for the slider, defaulting if invalid
    double initialMin = double.tryParse(widget.initialMinPrice) ?? 0;
    double initialMax = double.tryParse(widget.initialMaxPrice) ?? 10000;
    _selectedPriceRange = RangeValues(
      initialMin.clamp(0, 10000),
      initialMax.clamp(0, 10000),
    );
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
            // Price Range at the top
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
            const SizedBox(height: 20),

            // In-line Date Range Picker for Date Range Selection with highlighting
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SfDateRangePicker(
                view: DateRangePickerView.month, // Display month view
                selectionMode: DateRangePickerSelectionMode
                    .range, // Enable range selection
                initialSelectedRange:
                    (_selectedArrivalDate != null &&
                        _selectedDepartureDate != null)
                    ? PickerDateRange(
                        _selectedArrivalDate,
                        _selectedDepartureDate,
                      )
                    : null,
                minDate: DateTime.now(), // First selectable date
                maxDate: DateTime.now().add(
                  const Duration(days: 365 * 2),
                ), // Last selectable date (2 years from now)
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    if (args.value is PickerDateRange) {
                      _selectedArrivalDate = args.value.startDate;
                      _selectedDepartureDate = args.value.endDate;
                    }
                  });
                },
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  showTrailingAndLeadingDates:
                      true, // Show dates from prev/next month
                ),
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Theme.of(context).primaryColor,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selectionTextStyle: const TextStyle(color: Colors.white),
                rangeTextStyle: const TextStyle(color: Colors.white),
                startRangeSelectionColor: Theme.of(context).primaryColor,
                endRangeSelectionColor: Theme.of(context).primaryColor,
                rangeSelectionColor: Theme.of(context).primaryColor.withOpacity(
                  0.3,
                ), // Highlight color for the range
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Arrival: ${_selectedArrivalDate == null ? 'N/A' : DateFormat('yyyy-MM-dd').format(_selectedArrivalDate!)}',
                  ),
                  Text(
                    'Departure: ${_selectedDepartureDate == null ? 'N/A' : DateFormat('yyyy-MM-dd').format(_selectedDepartureDate!)}',
                  ),
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
