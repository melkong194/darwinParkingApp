import 'dart:ffi';

import 'package:darwin_parking/models/Destination.dart';
import 'package:darwin_parking/models/predicted_places.dart';
import 'package:darwin_parking/services/dataHandle.dart';
import 'package:darwin_parking/services/helpers_http.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global/map_key.dart';



class PlacePredictionTileDesign extends StatelessWidget
{
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  getPlaceDirectionDetails(String? placeId, context) async
  {

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await HelpersHttp.receiveRequest(placeDirectionDetailsUrl);

    if(responseApi == "Error Occurred, Failed. No Response.")
    {
      return;
    }

    if(responseApi["status"] == "OK")
    {
      Destination des = Destination();
      des.desAddress = responseApi["result"]["name"];
      des.desLat = responseApi["result"]["geometry"]["location"]["lat"];
      des.desLng = responseApi["result"]["geometry"]["location"]["lng"];
      // print(des.desAddress);
      // print(des.desLat);
      // print(des.desLng);
      Provider.of<DataHandle>(context, listen: false).updateDestination(des);
      Navigator.pop(context, "obtainedDestination");
    }

  }

  @override
  Widget build(BuildContext context)
  {
    return ElevatedButton(
      onPressed: ()
      {
        getPlaceDirectionDetails(predictedPlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: Colors.grey,
            ),
            const SizedBox(width: 14.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0,),
                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 2.0,),
                  Text(
                    predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8.0,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
