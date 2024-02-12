import 'package:flutter/cupertino.dart';
import 'package:driverapp/Models/address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation = Address(
      placeFormattedAddress: '',
      placeName: 'current location',
      placeId: '',
      latitude: 0.0,
      longitude: 0.0);

  late Address dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

   void updatedropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}

