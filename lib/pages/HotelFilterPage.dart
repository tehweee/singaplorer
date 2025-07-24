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
      appBar: AppBar(
        title: const Text('Filter Hotels'), // Title from your design
        centerTitle: true,
        backgroundColor: const Color(
          0xFFB11204,
        ), // Red color from your app's theme
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        // Added Container with gradient for the body background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0E0E0), // Light grey, similar to your app's background
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price Range section
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11204), // Red text for section title
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors.white, // White background for the price range box
                  borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    RangeSlider(
                      values: _selectedPriceRange,
                      min: 0,
                      max: 10000,
                      divisions: 100,
                      labels: RangeLabels(
                        '\$${_selectedPriceRange.start.round()}',
                        '\$${_selectedPriceRange.end.round()}',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _selectedPriceRange = values;
                        });
                      },
                      activeColor: const Color(0xFFB11204), // Red slider track
                      inactiveColor: Colors.grey[300],
                      overlayColor: MaterialStateProperty.all(
                        const Color(0xFFB11204).withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Min: \$${_selectedPriceRange.start.round()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Max: \$${_selectedPriceRange.end.round()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Date Range Selection section
              const Text(
                'Select Date Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11204), // Red text for section title
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Colors.white, // White background for the calendar box
                    borderRadius: BorderRadius.circular(
                      15.0,
                    ), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SfDateRangePicker(
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange:
                        (_selectedArrivalDate != null &&
                            _selectedDepartureDate != null)
                        ? PickerDateRange(
                            _selectedArrivalDate,
                            _selectedDepartureDate,
                          )
                        : null,
                    minDate: DateTime.now(),
                    maxDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                          setState(() {
                            if (args.value is PickerDateRange) {
                              _selectedArrivalDate = args.value.startDate;
                              _selectedDepartureDate = args.value.endDate;
                            }
                          });
                        },
                    monthViewSettings: const DateRangePickerMonthViewSettings(
                      showTrailingAndLeadingDates: true,
                      // weekendTextStyle and todayTextStyle removed from here
                    ),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: const Color(
                        0xFFB11204,
                      ), // Red header background
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selectionTextStyle: const TextStyle(color: Colors.white),
                    rangeTextStyle: const TextStyle(color: Colors.white),
                    startRangeSelectionColor: const Color(
                      0xFFB11204,
                    ), // Red selection color
                    endRangeSelectionColor: const Color(
                      0xFFB11204,
                    ), // Red selection color
                    rangeSelectionColor: const Color(
                      0xFFB11204,
                    ).withOpacity(0.3), // Light red highlight for range
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: const TextStyle(color: Colors.black87),
                      weekendTextStyle: const TextStyle(
                        color: Color(0xFFB11204),
                      ), // Red for weekends
                      todayTextStyle: const TextStyle(
                        color: Color(0xFFB11204),
                        fontWeight: FontWeight.bold,
                      ), // Red for today
                      todayCellDecoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFB11204),
                          width: 1,
                        ), // Red border for today
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arrival: ${_selectedArrivalDate == null ? 'N/A' : DateFormat('yyyy-MM-dd').format(_selectedArrivalDate!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Departure: ${_selectedDepartureDate == null ? 'N/A' : DateFormat('yyyy-MM-dd').format(_selectedDepartureDate!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity, // Make button fill width
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'arrivalDate': _selectedArrivalDate != null
                            ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedArrivalDate!)
                            : '',
                        'departureDate': _selectedDepartureDate != null
                            ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDepartureDate!)
                            : '',
                        'minPrice': _selectedPriceRange.start
                            .round()
                            .toString(),
                        'maxPrice': _selectedPriceRange.end.round().toString(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB11204), // Red button
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ), // Rounded button
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
