import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'helpers_http.dart';
import 'package:darwin_parking/global/map_key.dart';

class HelpersMethod
{
  static Future<String> positionToAddress(LatLng position) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";

    var requestResponse = await HelpersHttp.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.")
    {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      // Directions userPickUpAddress = Directions();
      // userPickUpAddress.locationLatitude = position.latitude;
      // userPickUpAddress.locationLongitude = position.longitude;
      // userPickUpAddress.locationName = humanReadableAddress;

      // Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

}