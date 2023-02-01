import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation =
      LatLng(-6.945311114917037, 107.60262214929439);
  static const LatLng destination =
      LatLng(-6.9434108453088275, 107.5734789956929);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((value) {
      currentLocation = value;
    });
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((event) {
      currentLocation = event;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(event!.latitude!, event!.longitude!), zoom: 13)));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyA96bPJjAD9l3PCnhaaAI3h67vRldVVl2g',
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/placeholder.png')
        .then((value) => sourceIcon = value);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/location.png')
        .then((value) => destinationIcon = value);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/google-maps.png')
        .then((value) => currentLocationIcon = value);
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(currentLocation);
    // currentLocation == null ? const CircularProgressIndicator() :
    return Scaffold(
      body: Center(
        child: currentLocation == null ? const CircularProgressIndicator() : GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!.toDouble(),
                        currentLocation!.longitude!.toDouble()),
                    zoom: 13),
                polylines: {
                  Polyline(
                      polylineId: const PolylineId('route'),
                      points: polylineCoordinates,
                      color: Colors.deepPurple,
                      width: 6),
                },
                markers: {
                  Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      icon: currentLocationIcon),
                  Marker(
                      markerId: const MarkerId('source'),
                      position: sourceLocation,
                      icon: sourceIcon),
                  Marker(
                      markerId: const MarkerId('destination'),
                      position: destination,
                      icon: destinationIcon)
                },
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
              ),
      ),
    );
  }
}
