import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:riderapp/AllScreens/loginscreen.dart';
import 'package:riderapp/AllScreens/searchScreen.dart';
import 'package:riderapp/AllWidgets/Divider.dart';
import 'package:riderapp/AllWidgets/progressDialog.dart';
import 'package:riderapp/DataHandler/appData.dart';
import 'package:riderapp/Helper/helperMethod.dart';
import 'package:riderapp/Models/directionDetails.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainscreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newgoogleMapController;
  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  double rideDetailsContainerHeight = 0;
  double searchContainerHeight = 300.0;
  double requestRideDetailsContainerHeight = 0;
  bool drawerOpen = true;

  void displayRequestRideContainer() {
    setState(() {
      requestRideDetailsContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newgoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address =
        await HelperMethod.searchCoordinateAddress(position, context);
    print("this is your address:" + address);
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.7917, -7.0926),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          "MainScreen",
        ),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand-Bold"),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text("Visit Profile"),
                          SizedBox(
                            height: 6.0,
                          ),
                          GestureDetector(
                              onTap: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.pushNamedAndRemoveUntil(context,
                                    LoginScreen.idScreen, (route) => false);
                              },
                              child: Text("sign out")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),
              SizedBox(
                height: 12.0,
              ),

              //drawer body
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newgoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 200.0;
              });
              locatePosition();
            },
          ),
          //button for drawer
          Positioned(
            top: 45.0,
            left: 32.0,
            child: GestureDetector(
              onTap: () {
                scaffoldkey.currentState?.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text(
                        "hi there,",
                        style: TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        "where to?",
                        style:
                            TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text("Search ")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context)
                                        .pickUpLocation
                                        .placeName ??
                                    "Add Home",
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your living home adress",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add place"),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your place adress",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.6,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/bigtax.png",
                                height: 70.0,
                                width: 80.0,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Brand-Bold"),
                                  ),
                                  Text(
                                    ((tripDirectionDetails != null)
                                        ? tripDirectionDetails?.distanceText ??
                                            ""
                                        : ''),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails != null)
                                    ? '\$${HelperMethod.calculateFares(tripDirectionDetails!)}'
                                    : ''),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheck,
                              size: 18.0,
                              color: Colors.black45,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Text("cash"),
                            SizedBox(
                              width: 6.0,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black45,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            displayRequestRideContainer();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,

                            // You can customize other button properties here, e.g., padding, elevation, shape, etc.
                          ),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "request ",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 26.0,
                                  )
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: requestRideDetailsContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "Requesting A ride...",
                          "please wait....",
                          "Finding Driver"
                        ],
                        textStyle: TextStyle(
                          fontSize: 55.0,
                          fontFamily: "Signatra",
                        ),
                        colors: [
                          Colors.blue,
                          Colors.purple,
                          Colors.green,
                        ],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    Container(
                      height: 60.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26.0),
                        border: Border.all(width: 2.0, color: Colors.grey),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 26.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng =
        LatLng(initialPos.latitude ?? 0.0, initialPos.longitude ?? 0.0);
    var dropOffLatLng =
        LatLng(finalPos.latitude ?? 0.0, finalPos.longitude ?? 0.0);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "WAIIT....",
            ));
    var details = await HelperMethod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    print("this is Encoded Points::");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();

    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints ?? "");
    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: PolylineId("PolyLineId"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newgoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "Drop Off Location"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );
    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
