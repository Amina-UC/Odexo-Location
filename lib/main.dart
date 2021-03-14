import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as p;
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'components/map_pin_pill.dart';
import 'models/pin_pill_info.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(9.9682, 76.318);

void main() =>
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MapPage()));

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}
String googleAPIKey = 'AIzaSyABBH07rVnsmRDsmIjtpfHiBuwczmyVyLk';
p.GoogleMapsPlaces _places = p.GoogleMapsPlaces(apiKey: googleAPIKey);
class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LatLng currentLocation;
// a reference to the destination location
  LatLng destinationLocation;
// wrapper around the location API
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  @override
  void initState() {
    super.initState();
    getDriverAddress();
    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event

    // set custom marker pins
    // setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
    getBytesFromAsset('assets/image/destination_map_marker.png', 64).then((onValue) {
      customIcon1 =BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/image/driving_pin.png', 64).then((onValue) {
      customIcon2 =BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/image/destination_map_marker.png', 64).then((onValue) {
      customIcon3 =BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/image/destination_map_marker.png', 64).then((onValue) {
      customIcon4 =BitmapDescriptor.fromBytes(onValue);
    });
  }

  Future getDriverAddress() async {
    final response = await http.get(
      //https://carecanadajobs.com/public/api/staffassigntickets?ticket_id=47
      Uri.encodeFull("https://oddexo.com/oddexo/services/API/autoServiceApi.php?service=driverLocation&driverid=856"),
    );
    var qData = json.decode(response.body);
    print("dxdcfgvbhkjnkm "+qData.toString());
    setState(() {
      // currentLocation = LatLng(qData["latitude"],qData["longitude"]);
      currentLocation = LatLng(9.9691,76.3217);
      destinationLocation = LatLng(9.9682, 76.318);
    });
    setState(() {
      _markers.clear();
    });
    showPinsOnMap();
  }


  Future updateLocation() async {
    final response = await http.get(
      //https://carecanadajobs.com/public/api/staffassigntickets?ticket_id=47
      Uri.encodeFull("https://oddexo.com/oddexo/services/API/autoServiceApi.php?service=driverLocationStatus&driverid=856&latitude="+currentLocation.latitude.toString()+"&longitude="+currentLocation.longitude.toString()),
    );
    var qData = json.decode(response.body);
    print("newww locccc "+qData.toString());
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      // currentLocation = LatLng(cLoc.latitude,cLoc.longitude);
      setState(() {
        currentLocation = LatLng(cLoc.latitude,cLoc.longitude);
      });
      updatePinOnMap();
    });
    // setState(() {
    //   _markers.clear();
    // });
    // showPinsOnMap();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), customIcon2.toString())
        .then((onValue) {
      sourceIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
        customIcon1.toString())
        .then((onValue) {
      destinationIcon = onValue;
    });
  }

  void setInitialLocation() async {
   /* Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.DENIED) {
        return;
      }
    }*/
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    /*setState(() async{
      // currentLocation = await location.getLocation();
    });*/

    // hard-coded destination for this example
    destinationLocation = DEST_LOCATION;
  }

  BitmapDescriptor customIcon1 ;
  BitmapDescriptor customIcon2 ;
  BitmapDescriptor customIcon3;
  BitmapDescriptor customIcon4 ;

  TextEditingController _loc = TextEditingController();

  Future<Null> displayPrediction(p.Prediction pp, ScaffoldState scaffold) async {
    if (pp != null) {
      // get detail (lat/lng)
      p.PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(pp.placeId);
      setState(() {
        destinationLocation = LatLng(detail.result.geometry.location.lat,detail.result.geometry.location.lng);
      });
      print("llllllaaaaaaaaattttttt %%%%%%%%%%%%%%%%%%% "+destinationLocation.toString());
      print("llllllaaaaaaaaattttttt %%%%%%%%%%%%%%%%%%% &&&&&&&&&&&&&&&&"+detail.result.geometry.location.toString());
      print("llllllaaaaaaaaattttttt "+detail.result.geometry.location.lat.toString());
      print("llllllongggg "+detail.result.geometry.location.lng.toString());
      setState(() {
        _markers.clear();
      });
      showPinsOnMap();
    }
  }
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  _timer(){
    return Timer(
        Duration(seconds: 30), (){
      updateLocation();
    }
    );

  }
  @override
  Widget build(BuildContext context) {
   _timer();
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Tracking"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _loc,

                  readOnly: true,
                  onTap: () async {
                    p.Prediction pat = await PlacesAutocomplete.show(
                      context: context,
                      apiKey: googleAPIKey,
                      onError: (error){
                        print("errrooorrr "+error.status);
                        print("errrooorrr msg"+error.errorMessage);
                      },
                      mode: Mode.overlay,
                      // Mode.fullscreen
                      language: "IN",
                      components: [
                        new p.Component(p.Component.country, "IN")
                      ],

                    );
                    displayPrediction(pat, homeScaffoldKey.currentState);
                    _loc.text = pat.description;
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[300],
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Colors.transparent
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Colors.transparent
                        )
                    ),
                    hintText: "Location",
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.location_on,color: Colors.black,size: 22,),
                    suffixIcon: GestureDetector(
                        onTap: (){

                        },
                        child: Icon(Icons.gps_fixed,color: Colors.black,size: 22,)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(height: height-200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black)
                  ),
                  child: GoogleMap(
                      myLocationEnabled: false,
                      compassEnabled: true,
                      tiltGesturesEnabled: false,
                      markers: _markers,
                      polylines: _polylines,zoomGesturesEnabled: true,
                      mapType: MapType.terrain,
                      initialCameraPosition: initialCameraPosition,
                      onTap: (LatLng loc) {
                        pinPillPosition = -100;
                      },
                      onMapCreated: (GoogleMapController controller) {
                        controller.setMapStyle(Utils.mapStyles);
                        _controller.complete(controller);
                        // my map has completed being created;
                        // i'm ready to show the pins on the map
                        showPinsOnMap();
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
/*MapPinPillComponent(
                    pinPillPosition: pinPillPosition,
                    currentlySelectedPin: currentlySelectedPin)*/
  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
    LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
    LatLng(destinationLocation.latitude, destinationLocation.longitude);

    sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: LatLng(currentLocation.latitude,currentLocation.longitude),
        pinPath: "assets/image/driving_pin.png",
        avatarPath: "assets/image/friend1.jpg",
        labelColor: Colors.greenAccent);

    destinationPinInfo = PinInformation(
        locationName: "End Location",
        location: destinationLocation,
        pinPath: "assets/image/destination_map_marker.png",
        avatarPath: "assets/image/friend2.jpg",
        labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: customIcon2));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: customIcon1));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);

    if (result.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear();
      });
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
            width: 3, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Colors.yellow[600],
            points: polylineCoordinates));
      });
    }
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
      sourcePinInfo.location = pinPosition;
      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: customIcon2));
    });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}