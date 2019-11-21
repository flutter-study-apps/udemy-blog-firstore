import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/map_route_form.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';

class Maproute extends StatefulWidget {
  @override
  _MaprouteState createState() => _MaprouteState();
}

class _MaprouteState extends State<Maproute> {
  GoogleMapController mapController;
  static const _initialGeoPosition =
      LatLng(14.828243, 120.281595); //from geo location
  LatLng _pickupLocation =
      _initialGeoPosition; //pickup location to be used for destination routing
  LatLng _destinationLocation = LatLng(14.826578, 120.282718);
  LatLng _cameraTarget = _initialGeoPosition;
  final Set<Polyline> _polyline = {};
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      // body: circularProgress(),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _destinationLocation, zoom: 18),
            onMapCreated: onCreated,
            mapType: MapType.normal,
            markers: _markers,
            polylines: _polyline,
            onCameraMove: _onCameraMove,
          ),
          MapRouteForm(
            topLocattion: 10,
            textForm: '',
            textHint: 'Select Pick up location',
            Iconform: Icons.my_location,
            onChange: () {},
          ),
          MapRouteForm(
            topLocattion: 65,
            textForm: '',
            textHint: '',
            Iconform: Icons.motorcycle,
            onChange: () {},
          ),
          Positioned(
            bottom: 30,
            right: 10,
            child: FloatingActionButton(
              onPressed: _onAddMarkerPressed,
              child: Icon(Icons.pin_drop),
            ),
          )
        ],
      ),
    );
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _cameraTarget = position.target;
    print(position.target);
  }

  void _onAddMarkerPressed() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(_cameraTarget.toString()),
          position: _cameraTarget,
          infoWindow: InfoWindow(
            title: "Remember Here",
            snippet: "good place",
          ),
          icon: BitmapDescriptor
              .defaultMarker, //the actual design of the pin in the map
        ),
      );
    });
  }
}

