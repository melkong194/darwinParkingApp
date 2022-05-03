import 'package:darwin_parking/models/Destination.dart';
import 'package:flutter/cupertino.dart';

class DataHandle extends ChangeNotifier
{
  Destination? destination;
  void updateDestination(Destination des)
  {
    destination = des;
  }


}