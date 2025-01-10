import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapScreen extends StatefulWidget {
  final LatLng start;
  final LatLng end;

  const GoogleMapScreen({
    Key? key,
    required this.start,
    required this.end,
  }) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  String _selectedVehicle = "car";
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setMarkersAndRoute();
  }

  void _setMarkersAndRoute() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('start'),
          position: widget.start,
          infoWindow: const InfoWindow(title: 'Start Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: widget.end,
          infoWindow: const InfoWindow(title: 'End Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [widget.start, widget.end],
          color: Colors.red,
          width: 5,
        ),
      };
    });
  }

  // Function to display the vehicle selection dialog
  Future<void> _showVehicleSelectionDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Vehicle Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Car'),
                onTap: () {
                  Navigator.of(context).pop('car');
                },
              ),
              ListTile(
                title: const Text('Truck'),
                onTap: () {
                  Navigator.of(context).pop('truck');
                },
              ),
              ListTile(
                title: const Text('Bike'),
                onTap: () {
                  Navigator.of(context).pop('bike');
                },
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedVehicle = selected;
      });

      // Now show the specification form based on the vehicle type
      await _showVehicleSpecificationForm();
    }
  }

  // Show additional vehicle specifications form based on vehicle type
  Future<void> _showVehicleSpecificationForm() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Vehicle Specifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedVehicle == 'truck') ...[
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height (in meters)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (in tons)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'Cargo Capacity (in tons)'),
                  keyboardType: TextInputType.number,
                ),
              ],
              if (_selectedVehicle == 'car') ...[
                TextField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'Passenger Capacity'),
                  keyboardType: TextInputType.number,
                ),
              ],
              if (_selectedVehicle == 'bike') ...[
                TextField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'Bike Type (e.g., Scooter, Sports)'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchCustomRoute();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Fetch custom route based on selected vehicle and specifications
  Future<void> _fetchCustomRoute() async {
    String routingMode = 'driving'; // Default for car

    // Add custom logic based on vehicle type and specifications
    if (_selectedVehicle == 'truck') {
      // Add logic to check height, weight, capacity, etc., to suggest routes
      routingMode = 'truck'; // Truck-specific routes
    } else if (_selectedVehicle == 'bike') {
      routingMode = 'bicycle'; // Bike-specific routes
    }

    final googleMapsUri = Uri.parse(
        'google.navigation:q=${widget.end.latitude},${widget.end.longitude}&mode=$routingMode');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${widget.start.latitude},${widget.start.longitude}&destination=${widget.end.latitude},${widget.end.longitude}&travelmode=$routingMode');

    try {
      // Attempt to launch Google Maps app URL
      if (await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication)) {
        return; // Successfully launched Google Maps app
      }

      // Fallback: Attempt to launch web URL
      if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
        return; // Successfully launched in browser
      }

      throw 'Unable to launch directions in either app or browser.';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening directions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Map Screen')),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true, // Show the "My Location" button by default
            myLocationEnabled: true,      // Enable showing the user's location
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.start.latitude + widget.end.latitude) / 2,
                (widget.start.longitude + widget.end.longitude) / 2,
              ),
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController.animateCamera(
                CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: LatLng(
                      widget.start.latitude < widget.end.latitude
                          ? widget.start.latitude
                          : widget.end.latitude,
                      widget.start.longitude < widget.end.longitude
                          ? widget.start.longitude
                          : widget.end.longitude,
                    ),
                    northeast: LatLng(
                      widget.start.latitude > widget.end.latitude
                          ? widget.start.latitude
                          : widget.end.latitude,
                      widget.start.longitude > widget.end.longitude
                          ? widget.start.longitude
                          : widget.end.longitude,
                    ),
                  ),
                  50.0,
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                // Show vehicle selection dialog before showing directions
                await _showVehicleSelectionDialog();
              },
              child: const Text(
                'Show Directions',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
