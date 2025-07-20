import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArrivalFilterPage extends StatefulWidget {
  final String to;
  final String depart;
  final String cabin;
  final String sort;
  final String pax;

  const ArrivalFilterPage({
    super.key,
    required this.to,
    required this.depart,
    required this.cabin,
    required this.sort,
    this.pax = '1',
  });

  @override
  State<ArrivalFilterPage> createState() => _ArrivalFilterPageState();
}

class _ArrivalFilterPageState extends State<ArrivalFilterPage> {
  late TextEditingController _toController;
  late TextEditingController _paxController;
  late String _selectedCabin;
  late String _selectedSort;
  late DateTime _selectedDate;

  final _cabinOptions = ['ECONOMY', 'PREMIUM_ECONOMY', 'BUSINESS', 'FIRST'];
  final _sortOptions = ['BEST', 'CHEAPEST', 'FASTEST'];

  @override
  void initState() {
    super.initState();
    _toController = TextEditingController(text: widget.to);
    _paxController = TextEditingController(text: widget.pax);
    _selectedCabin = widget.cabin;
    _selectedSort = widget.sort;
    _selectedDate = DateTime.tryParse(widget.depart) ?? DateTime.now();
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'to': _toController.text,
      'depart': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'cabin': _selectedCabin,
      'sort': _selectedSort,
      'pax': _paxController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Filters')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(
                        labelText: 'To (e.g. LHR.AIRPORT)',
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _paxController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Passengers',
                      ),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField(
                      value: _selectedCabin,
                      items: _cabinOptions
                          .map(
                            (cabin) => DropdownMenuItem(
                              value: cabin,
                              child: Text(cabin),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCabin = value!),
                      decoration: InputDecoration(labelText: 'Cabin Class'),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField(
                      value: _selectedSort,
                      items: _sortOptions
                          .map(
                            (sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(sort),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSort = value!),
                      decoration: InputDecoration(labelText: 'Sort By'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Departure Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: CalendarDatePicker(
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          onDateChanged: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ),
                    ),
                    Spacer(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
