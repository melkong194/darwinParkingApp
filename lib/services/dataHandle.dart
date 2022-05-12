import 'package:darwin_parking/models/Destination.dart';
import 'package:darwin_parking/models/user_location.dart';
import 'package:flutter/cupertino.dart';

import '../models/destination_address.dart';

class DataHandle extends ChangeNotifier
{
  Destination? destination;
  UserLocation? userLocation;
  DestinationAdd? destinationAdd;
  void updateDestination(Destination des)
  {
    destination = des;
  }

  void updateUserLocation(UserLocation u)
  {
    userLocation = u;
  }

  void updateDestinationAdd(DestinationAdd add)
  {
    destinationAdd = add;
  }
}