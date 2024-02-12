import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:driverapp/DataHandler/appData.dart';
import 'package:driverapp/Helper/requesthelper.dart';
import 'package:driverapp/Models/address.dart';
import 'package:driverapp/Models/directionDetails.dart';
import 'package:driverapp/configMaps.dart';

class HelperMethod {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestHelper.getRequest(url);
    if (response != "Failed") {
      //placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][1]["long_name"];
      st2 = response["results"][0]["address_components"][3]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + "," + st2 + "," + st3 + "," + st4;

      Address userPickUpAddress = Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${finalPosition.latitude},${finalPosition.longitude}&origin=${initialPosition.latitude},${initialPosition.longitude}&key=${mapKey}";

    var res = await RequestHelper.getRequest(directionUrl);
    print("Direction API Response: $res");

    if (res == "failed" || res["routes"] == null || res["routes"].isEmpty) {
      // Handle the case where directions are not available
      return DirectionDetails(
        encodedPoints: "",
        distanceText: "",
        distanceValue: 0,
        durationText: "",
        durationValue: 0,
      );
    }

    DirectionDetails directionDetails = DirectionDetails();

    // Check if routes array is not empty before attempting to access its elements
    if (res["routes"].isNotEmpty) {
      print("Routes: ${res["routes"]}");
      directionDetails.encodedPoints =
          res["routes"][0]["overview_polyline"]["points"] ?? "";
    }

    print("Directions: $directionDetails");

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"] ?? "";
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"] ?? 0;
    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"] ?? "";
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"] ?? 0;

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.distanceValue! / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;
    return totalFareAmount.truncate();
  }

 
}
