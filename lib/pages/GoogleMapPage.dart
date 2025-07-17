import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapData extends StatelessWidget {
  const GoogleMapData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Day 1 destinations with coordinates (Singapore locations)
    final List<Map<String, dynamic>> day1Destinations = const [
      {
        'name': 'Hotel Check-in',
        'lat': 1.2966,
        'lng': 103.8547,
        'address': 'Singapore Hotel (Marina Bay area)',
        'description': 'Arrive in Singapore & Check into your hotel',
      },
      {
        'name': 'test',
        'lat': 1.37223,
        'lng': 103.8369,
        'address': 'test',
        'description': 'test',
      },
      {
        'name': 'Gardens by the Bay',
        'lat': 1.2816,
        'lng': 103.8636,
        'address': 'Gardens by the Bay, Singapore',
        'description': 'Explore Gardens by the Bay',
      },
      {
        'name': 'Cloud Forest & Flower Dome',
        'lat': 1.2815,
        'lng': 103.8639,
        'address': 'Cloud Forest & Flower Dome, Gardens by the Bay',
        'description': 'Visit Cloud Forest & Flower Dome',
      },
      {
        'name': 'Supertree Grove',
        'lat': 1.2813,
        'lng': 103.8634,
        'address': 'Supertree Grove, Gardens by the Bay',
        'description': 'Walk through Supertree Grove',
      },
      {
        'name': 'Marina Bay Sands',
        'lat': 1.2834,
        'lng': 103.8607,
        'address': 'Marina Bay Sands, Singapore',
        'description': 'Walk around Marina Bay Sands',
      },
      {
        'name': 'Marina Bay Sands SkyPark',
        'lat': 1.2836,
        'lng': 103.8607,
        'address': 'SkyPark Observation Deck, Marina Bay Sands',
        'description': 'Visit Marina Bay Sands SkyPark (observation deck)',
      },
      {
        'name': 'Lau Pa Sat',
        'lat': 1.2806,
        'lng': 103.8505,
        'address': 'Lau Pa Sat Food Centre, Singapore',
        'description':
            'Dinner at Lau Pa Sat (local food with satay street at night)',
      },
    ];

    return MaterialApp(
      title: 'Travel Itinerary',
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Roboto'),
      home: GoogleMapPage(destinations: day1Destinations),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoogleMapPage extends StatefulWidget {
  final List<Map<String, dynamic>> destinations;

  const GoogleMapPage({Key? key, required this.destinations}) : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines =
      {}; // Will hold multiple polylines for detailed routes
  int _selectedDestinationIndex = 0;
  List<Map<String, dynamic>> _routeSteps =
      []; // Stores detailed steps for the selected route
  Map<String, dynamic>?
  _overallRouteSummary; // Stores overall distance and duration for the selected route
  bool _isLoadingRoute = false;
  String _selectedTransportMode = 'driving'; // Default transport mode

  // !! Replace with your actual Google Maps API key !!
  static const String _googleMapsApiKey =
      'AIzaSyAFyK4-ffQpm-1oZJzRIR4qu0T4L8ACDwM';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers(); // Create markers for all destinations and current location
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (permission == PermissionStatus.granted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _getDirections(); // After getting current location, get directions to the initially selected destination
        }
      } else {
        // Handle the case where permission is not granted (e.g., show a message, use default location)
        _useDefaultLocationAndGetDirections();
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      _useDefaultLocationAndGetDirections();
    }
  }

  void _useDefaultLocationAndGetDirections() {
    if (mounted) {
      setState(() {
        _currentPosition = Position(
          latitude: 1.2966, // Default to Marina Bay, Singapore
          longitude: 103.8547,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });
      _getDirections(); // Get directions with default location
    }
  }

  void _createMarkers() {
    Set<Marker> markers = {};

    for (int i = 0; i < widget.destinations.length; i++) {
      final destination = widget.destinations[i];
      markers.add(
        Marker(
          markerId: MarkerId('destination_$i'),
          position: LatLng(destination['lat'], destination['lng']),
          infoWindow: InfoWindow(
            title: destination['name'],
            snippet: destination['description'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed, // All destination markers are red
          ),
          onTap: () {
            if (mounted) {
              setState(() {
                _selectedDestinationIndex = i; // Update selected index
                _selectedTransportMode =
                    'driving'; // Reset to driving when a new destination is tapped
              });
              _getDirections(); // Re-calculate directions to this selected destination
            }
          },
        ),
      );
    }

    // Add current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Starting point',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  Future<void> _getDirections() async {
    // Ensure we have a current position and at least one destination
    if (_currentPosition == null || widget.destinations.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _polylines.clear();
          _routeSteps.clear();
          _overallRouteSummary = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingRoute = true;
        _polylines.clear(); // Clear existing polylines
        _routeSteps.clear(); // Clear existing route steps
        _overallRouteSummary = null; // Clear overall summary
      });
    }

    try {
      // Get the coordinates of the currently selected destination
      final LatLng selectedDestinationLatLng = LatLng(
        widget.destinations[_selectedDestinationIndex]['lat'],
        widget.destinations[_selectedDestinationIndex]['lng'],
      );

      String travelMode = _getTravelModeForAPI(_selectedTransportMode);

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&'
          // Route only to the selected destination
          'destination=${selectedDestinationLatLng.latitude},${selectedDestinationLatLng.longitude}&'
          'mode=$travelMode&'
          'key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          _parseDirectionsResponse(data);
        } else {
          debugPrint('Directions API error: ${data['status']}');
          _showErrorSnackbar('Could not get directions: ${data['status']}');
          if (mounted) {
            setState(() {
              _polylines.clear();
              _routeSteps.clear();
              _overallRouteSummary = null;
            });
          }
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        _showErrorSnackbar('Network error: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _polylines.clear();
            _routeSteps.clear();
            _overallRouteSummary = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting directions: $e');
      _showErrorSnackbar('An unexpected error occurred: $e');
      if (mounted) {
        setState(() {
          _polylines.clear();
          _routeSteps.clear();
          _overallRouteSummary = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  void _parseDirectionsResponse(Map<String, dynamic> data) {
    List<Map<String, dynamic>> stepsList = [];
    Set<Polyline> polylines = {}; // This will now hold multiple polylines
    Map<String, dynamic>? currentOverallSummary;

    if (data['routes'].isNotEmpty) {
      final route = data['routes'][0];
      final legs = route['legs'] as List;

      if (legs.isNotEmpty) {
        final leg = legs[0]; // The single leg for the A to B route

        // Store overall summary for this route
        currentOverallSummary = {
          'distance': leg['distance']['text'] ?? 'N/A',
          'duration': leg['duration']['text'] ?? 'N/A',
          'startAddress': leg['start_address'] ?? 'N/A',
          'endAddress': leg['end_address'] ?? 'N/A',
        };

        // Iterate through the steps within this leg to create individual polylines
        final steps = leg['steps'] as List;
        for (int i = 0; i < steps.length; i++) {
          final step = steps[i];
          final String travelMode = step['travel_mode'];
          String stepInstruction =
              step['html_instructions'] ?? 'No instruction';
          String stepDistance = step['distance']['text'] ?? '';
          String stepDuration = step['duration']['text'] ?? '';

          Map<String, dynamic> stepData = {
            'index': i + 1, // 1-based index for display
            'instruction': stripHtmlTags(stepInstruction), // Strip HTML tags
            'distance': stepDistance,
            'duration': stepDuration,
            'type': travelMode
                .toLowerCase(), // 'transit', 'walking', 'driving', 'bicycling'
          };

          // Decode polyline for this specific step
          String stepEncodedPolyline = step['polyline']['points'];
          List<LatLng> stepPolylinePoints = _decodePolyline(
            stepEncodedPolyline,
          );

          // Determine color and pattern based on travel mode/vehicle type for transit
          Color polylineColor = Colors.grey; // Default color
          List<PatternItem> polylinePattern = []; // Default pattern

          if (_selectedTransportMode == 'transit') {
            if (travelMode == 'TRANSIT' &&
                step.containsKey('transit_details')) {
              final transitDetails = step['transit_details'];
              final line = transitDetails['line'];
              String vehicleType = (line['vehicle']['type'] ?? '')
                  .toLowerCase();

              stepData.addAll({
                'lineName': line['name'] ?? 'N/A',
                'lineShortName': line['short_name'] ?? 'N/A',
                'vehicleType': vehicleType, // Store lowercase
                'departureStop':
                    transitDetails['departure_stop']['name'] ?? 'N/A',
                'arrivalStop': transitDetails['arrival_stop']['name'] ?? 'N/A',
                'numStops': transitDetails['num_stops'] ?? 0,
                'departureTime': transitDetails['departure_time'] != null
                    ? transitDetails['departure_time']['text']
                    : null,
                'arrivalTime': transitDetails['arrival_time'] != null
                    ? transitDetails['arrival_time']['text']
                    : null,
              });

              if (vehicleType == 'subway' ||
                  vehicleType == 'train' ||
                  vehicleType == 'rail') {
                polylineColor = Colors.red.shade700; // Deep Red for MRT/Train
              } else if (vehicleType == 'bus') {
                polylineColor =
                    Colors.lightGreen.shade700; // Darker light green for Bus
              } else {
                polylineColor = Colors.purple; // Other transit types
              }
            } else if (travelMode == 'WALKING') {
              polylineColor = Colors
                  .blue
                  .shade700; // Darker blue for Walking segments in transit
              polylinePattern = [
                PatternItem.dash(30),
                PatternItem.gap(10),
              ]; // Dashed line for walking
            } else {
              polylineColor =
                  Colors.grey; // Fallback for other modes within transit if any
            }
          } else {
            // If not in transit mode, use a single solid color for the entire route
            polylineColor = const Color(
              0xFFB71C1C,
            ); // Default red for the single overall route
            // No patterns for a single solid line
          }

          polylines.add(
            Polyline(
              polylineId: PolylineId(
                'step_$i',
              ), // Unique ID for each step polyline
              points: stepPolylinePoints,
              color: polylineColor,
              width: _selectedTransportMode == 'transit'
                  ? 6
                  : 5, // Slightly thicker for transit steps
              patterns: _selectedTransportMode == 'transit'
                  ? polylinePattern
                  : [], // Apply patterns only for transit steps
              geodesic: true, // Recommended for accuracy
            ),
          );
          stepsList.add(stepData);
        }
      }
    } else {
      // Handle case where no routes are found for the selected mode/destination
      _showErrorSnackbar('No route found for the selected mode.');
    }

    if (mounted) {
      setState(() {
        _polylines =
            polylines; // Now contains multiple polylines if transit, or one if other
        _routeSteps = stepsList;
        _overallRouteSummary = currentOverallSummary;
      });
      _fitMapToRoute(); // Adjust map camera to show the entire route
    }
  }

  void _fitMapToRoute() {
    if (_mapController != null && _polylines.isNotEmpty) {
      LatLngBounds bounds;
      // If there are no points in the first polyline, return. This is a safeguard.
      if (_polylines.isEmpty || _polylines.first.points.isEmpty) return;

      // Collect all points from all polylines to calculate bounds
      double minLat = double.infinity;
      double minLng = double.infinity;
      double maxLat = double.negativeInfinity;
      double maxLng = double.negativeInfinity;

      for (var polyline in _polylines) {
        for (var point in polyline.points) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }
      }

      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      // Use a padding to ensure the route and markers are visible
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylinePoints;
  }

  String _getTravelModeForAPI(String mode) {
    switch (mode.toLowerCase()) {
      case 'driving':
        return 'driving';
      case 'walking':
        return 'walking';
      case 'bicycling':
        return 'bicycling';
      case 'transit':
        return 'transit';
      default:
        return 'driving';
    }
  }

  IconData _getTransportIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'driving':
        return Icons.directions_car;
      case 'walking':
        return Icons.directions_walk;
      case 'bicycling':
        return Icons.directions_bike;
      case 'subway':
      case 'train':
      case 'rail': // Added 'rail' as some APIs use it
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'transit': // Generic transit icon if type is unknown or general
        return Icons.directions_transit;
      default:
        return Icons.directions_car;
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Utility function to strip HTML tags from strings
  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  // --- Start of _buildTransportModeButton method ---
  Widget _buildTransportModeButton(String label, String mode, IconData icon) {
    bool isSelected = _selectedTransportMode == mode;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedTransportMode = mode;
          });
          _getDirections(); // Recalculate directions with new mode
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFB71C1C) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[800],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- End of _buildTransportModeButton method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        elevation: 0,
        title: const Text(
          'Day 1 Route',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_isLoadingRoute)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        // Use Stack to layer the map and the draggable sheet
        children: [
          // Google Maps Widget (fixed at the back)
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _fitMapToRoute(); // Fit map to route when controller is ready
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition?.latitude ??
                    1.2816, // Default to Gardens by the Bay
                _currentPosition?.longitude ?? 103.8636,
              ),
              zoom: 13.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled:
                false, // Set to false to hide default zoom controls
            mapType: MapType.normal,
          ),

          // Custom Zoom Controls (Top Left)
          Positioned(
            top: 10, // Adjust as needed for padding from top
            left: 10, // Adjust as needed for padding from left
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoomInBtn', // Unique tag for FloatingActionButtons
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  // mini: true, // REMOVED THIS LINE
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[800],
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8), // Spacing between buttons
                FloatingActionButton.small(
                  heroTag: 'zoomOutBtn', // Unique tag
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  // mini: true, // REMOVED THIS LINE
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[800],
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // Draggable Scrollable Sheet for the bottom panel
          DraggableScrollableSheet(
            initialChildSize:
                0.5, // Increased initial height to show more content
            minChildSize: 0.2, // Minimum height when fully collapsed
            maxChildSize: 0.9, // Maximum height when fully expanded
            expand: true, // Allows the sheet to expand to full height
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  // Allow content inside to scroll
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Handle for dragging
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Transport Mode Selection
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTransportModeButton(
                                  'Driving',
                                  'driving',
                                  Icons.directions_car,
                                ),
                                _buildTransportModeButton(
                                  'Walking',
                                  'walking',
                                  Icons.directions_walk,
                                ),
                                _buildTransportModeButton(
                                  'Bicycling',
                                  'bicycling',
                                  Icons.directions_bike,
                                ),
                                _buildTransportModeButton(
                                  'Transit',
                                  'transit',
                                  Icons.directions_transit,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Route Summary Info for the selected route
                            if (_overallRouteSummary != null &&
                                !_isLoadingRoute)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Route to: ${widget.destinations[_selectedDestinationIndex]['name']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB71C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Duration: ${_overallRouteSummary!['duration']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.straighten,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Distance: ${_overallRouteSummary!['distance']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else if (!_isLoadingRoute &&
                                _overallRouteSummary == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'Select a destination or transport mode to see route summary.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      // --- Dynamic Content: Transit Steps or Destinations List ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.route,
                                  color: Color(0xFFB71C1C),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTransportMode == 'transit'
                                      ? 'Transit Route Steps'
                                      : 'Day 1 Destinations',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingRoute)
                              const Center(child: CircularProgressIndicator())
                            else if (_selectedTransportMode == 'transit')
                              // Display transit route steps
                              _routeSteps.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No transit route details available.',
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap:
                                          true, // Important for ListView inside SingleChildScrollView
                                      physics:
                                          const NeverScrollableScrollPhysics(), // Handled by parent SingleChildScrollView
                                      itemCount: _routeSteps.length,
                                      itemBuilder: (context, i) {
                                        final step = _routeSteps[i];
                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Step number and instruction
                                                Text(
                                                  '${step['index']}. ${step['instruction']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                if (step['type'] ==
                                                    'transit') ...[
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        _getTransportIcon(
                                                          step['vehicleType']
                                                              .toLowerCase(),
                                                        ),
                                                        size: 16,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${step['vehicleType']}: ${step['lineShortName']} (${step['lineName']})',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .blueAccent,
                                                                fontSize: 13,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'From: ${step['departureStop']}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    'To: ${step['arrivalStop']} (${step['numStops']} stops)',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  if (step['departureTime'] !=
                                                      null)
                                                    Text(
                                                      'Departs: ${step['departureTime']}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  if (step['arrivalTime'] !=
                                                      null)
                                                    Text(
                                                      'Arrives: ${step['arrivalTime']}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                ],
                                                // Always show duration and distance for any step
                                                Text(
                                                  'Duration: ${step['duration']} | Distance: ${step['distance']}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                            else
                              // Display day 1 destinations for other modes
                              ListView.builder(
                                shrinkWrap:
                                    true, // Important for ListView inside SingleChildScrollView
                                physics:
                                    const NeverScrollableScrollPhysics(), // Handled by parent SingleChildScrollView
                                itemCount: widget.destinations.length,
                                itemBuilder: (context, index) {
                                  final destination =
                                      widget.destinations[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: index == _selectedDestinationIndex
                                          ? const Color(
                                              0xFFB71C1C,
                                            ).withOpacity(0.1)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            index == _selectedDestinationIndex
                                            ? const Color(0xFFB71C1C)
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedDestinationIndex = index;
                                          _selectedTransportMode =
                                              'driving'; // Reset mode for new destination tap
                                        });
                                        _mapController?.animateCamera(
                                          CameraUpdate.newLatLng(
                                            LatLng(
                                              destination['lat'],
                                              destination['lng'],
                                            ),
                                          ),
                                        );
                                        _getDirections();
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB71C1C),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  destination['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  destination['description'] ??
                                                      destination['address'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
