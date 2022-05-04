import 'package:darwin_parking/models/Destination.dart';
import 'package:darwin_parking/models/user_location.dart';
import 'package:flutter/cupertino.dart';

class DataHandle extends ChangeNotifier
{
  Destination? destination;
  UserLocation? userLocation;
  void updateDestination(Destination des)
  {
    destination = des;
  }

  void updateUserLocation(UserLocation u)
  {
    userLocation = u;
  }
}