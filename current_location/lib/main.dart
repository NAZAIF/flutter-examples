import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Circle circle;
  GoogleMapController _controller;
  String appBarTitle = 'Map Demo';
  BitmapDescriptor myIcon;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(11.259508,75.791760),
    zoom: 14.4746,
  );

  void updateCircle(LocationData newLocalData) {
    LatLng latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      appBarTitle = "${newLocalData.latitude.toString()} ${newLocalData.longitude.toString()}";
      circle = Circle(
        strokeWidth: 2,
          circleId: CircleId("id"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latLng,
          fillColor: Colors.blue.withAlpha(70)
    );
    });
  }

  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();

      updateCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
            if (_controller != null) {
              _controller.animateCamera(
                  CameraUpdate.newCameraPosition(new CameraPosition(
                      target: LatLng(
                          newLocalData.latitude, newLocalData.longitude),
                      bearing: 192.83349,
                      tilt: 0,
                      zoom: 18
                  )));
              updateCircle(newLocalData);
            }
          });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION DENIED') {
        debugPrint("Permission denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: GoogleMap(
        initialCameraPosition: initialLocation,
        mapType: MapType.hybrid,
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCurrentLocation();
        },
        child: Icon(Icons.location_searching),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
