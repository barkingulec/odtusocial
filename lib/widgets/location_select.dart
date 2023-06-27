import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';


class LocationPicker extends StatefulWidget {
  final position;
  final communityId;
  final eventId;

  const LocationPicker({Key? key, required this.position, required this.communityId, required this.eventId}) : super(key: key);
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  var cameraLocation;
  var location;
  var lat;
  var lng;
  var _markers;
  var eventRef;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    location = widget.position;
    lat = location.latitude;
    lng = location.longitude;
    cameraLocation = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 17,
    );
    _markers = Set<Marker>.of(
          <Marker>[
            Marker(
              draggable: true,
              markerId: MarkerId("1"),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: const InfoWindow(
                title: 'Selected Location',
              ),
            )
          ],
        );

    eventRef = FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId);

    setState(() {
      
    });

  }

    updateEvent() {
      eventRef.update({
        "location": GeoPoint(location.latitude, location.longitude)
      });
      //FireStoreMethods().updateNotificationOnEventUpdate(widget.communityId, widget.eventId, _selectedOptions, prevSelectedOptions);
      showSnackBar(context, "Location Updated.");
      Navigator.pop(context);
  }

  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: _markers,
            onTap: _handleTap,
            //onCameraMove: ((_position) => _updatePosition(_position)),
            mapType: MapType.normal,
            initialCameraPosition: cameraLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 8),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: updateEvent,
                child: const Icon(Icons.arrow_forward_ios_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }

_handleTap(LatLng point) {
  setState(() {
    location = point;
    _markers.add(
      Marker(
        markerId: MarkerId('2'),
        position: location,
        infoWindow: InfoWindow(
          title: 'Selected Location',
        ),
        //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
  });
}

  // void _updatePosition(CameraPosition _position) {
  //   Position newMarkerPosition = Position(
  //       latitude: _position.target.latitude,
  //       longitude: _position.target.longitude);
  //   Marker marker = markers["1"];

  //   setState(() {
  //     markers["1"] = marker.copyWith(
  //         positionParam: LatLng(newMarkerPosition.latitude, newMarkerPosition.longitude));
  //   });
  // }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}