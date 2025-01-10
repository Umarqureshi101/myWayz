import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'map_page.dart';
import 'googlemap_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// New Screen to navigate to
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: const Center(
        child: Text('This is the details screen!'),
      ),
    );
  }
}

// StatefulWidget to hold the RouteMapScreen state
class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  // Controllers for start and end location input fields
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  // Variable to store the selected vehicle type (car, truck, etc.)
  String _selectedVehicle = 'car';

  // Variables to store the coordinates for start and end markers
  LatLng? _startMarker;
  LatLng? _endMarker;

  // Controller for the map
  final MapController _mapController = MapController();

  // A map to store vehicle types
  final Map<String, String> _vehicleTypes = {
    'car': 'Car',
    'truck': 'Truck',
    'bicycle': 'Bicycle',
    'pedestrian': 'Pedestrian',
  };

  // Function to fetch coordinates from the Geoapify API based on location
  Future<void> _fetchCoordinates(String location, bool isStart) async {
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid location')),
      );
      return;
    }

    final apiKey = '9068c95b8fff4784a859b59cdc429e56'; // Your Geoapify API key
    final url =
        'https://api.geoapify.com/v1/geocode/search?text=$location&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        if (features.isNotEmpty) {
          final coordinates = features.first['geometry']['coordinates'];
          LatLng position = LatLng(coordinates[1], coordinates[0]);

          setState(() {
            if (isStart) {
              _startMarker = position;
              _startController.text = features.first['properties']['formatted'];
            } else {
              _endMarker = position;
              _endController.text = features.first['properties']['formatted'];
            }

            if (_startMarker != null && _endMarker != null) {
              _mapController.fitBounds(
                LatLngBounds.fromPoints([_startMarker!, _endMarker!]),
                options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No location found')),
          );
        }
      } else {
        throw Exception('Failed to fetch coordinates');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching coordinates: $e')),
      );
    }
  }

  // Function to draw a line between the start and end markers
  void _drawLineBetweenMarkers() {
    if (_startMarker == null || _endMarker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set both start and end locations')),
      );
      return;
    }

    _mapController.fitBounds(
      LatLngBounds.fromPoints([_startMarker!, _endMarker!]),
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Map')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _selectedVehicle,
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicle = value!;
                    });
                  },
                  items: _vehicleTypes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    labelText: 'Start Location',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () =>
                          _fetchCoordinates(_startController.text, true),
                    ),
                  ),
                ),
                TextField(
                  controller: _endController,
                  decoration: InputDecoration(
                    labelText: 'End Location',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () =>
                          _fetchCoordinates(_endController.text, false),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _drawLineBetweenMarkers,
                  child: const Text('Get Route'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(0, 0),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_startMarker != null)
                      Marker(
                        point: _startMarker!,
                        builder: (_) => const Icon(Icons.location_pin,
                            color: Colors.green, size: 37),
                      ),
                    if (_endMarker != null)
                      Marker(
                        point: _endMarker!,
                        builder: (_) => const Icon(Icons.location_pin,
                            color: Colors.blue, size: 39),
                      ),
                  ],
                ),
                if (_startMarker != null && _endMarker != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_startMarker!, _endMarker!],
                        strokeWidth: 5.0,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      // Navigation Button at the bottom with a fancy UI
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15), // Padding
            elevation: 3, // Shadow for a 3D effect
            shadowColor: Colors.black, // Shadow color
          ),
          onPressed: () {
            if (_startMarker != null && _endMarker != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoogleMapScreen(
                    start: gmaps.LatLng(_startMarker!.latitude, _startMarker!.longitude),
                    end: gmaps.LatLng(_endMarker!.latitude, _endMarker!.longitude),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please set both start and end locations')),
              );
            }
          },
          child: const Text(
            'Go to Google Map Screen',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold, // Make text bold
              color: Colors.white, // White text color
            ),
          ),
        ),
      ),

    );
  }
}
