import 'dart:async';
import 'package:darwin_parking/mainScreen/search_places_screen.dart';
import 'package:darwin_parking/models/Destination.dart';
import 'package:darwin_parking/services/dataHandle.dart';
import 'package:darwin_parking/services/helpers_method.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin
{
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.8968, 155.5828),
    zoom: 14.4746,
  );

  //Variables Declare
  double searchBoxHeight = 220;
  Position? userPosition;
  var geoLocator = Geolocator();
  List<Marker> myMarker = [];
  LocationPermission? _locationPermission;
  String readAddress = "";

  //Methods Defined
  checkLocationPermission() async{
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy : LocationAccuracy.high);
    userPosition = cPosition;
    LatLng latlngPosition = LatLng(userPosition!.latitude, userPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target:latlngPosition, zoom: 20);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Set<Polygon> myPolygon() {

    Set<Polygon> polygonSet = {};
    List<LatLng> polygon = [];
    polygon.add(const LatLng(-12.4656335, 130.8416195));
    polygon.add(const LatLng(-12.4656557, 130.8416436));
    polygon.add(const LatLng(-12.4656125, 130.8416879));
    polygon.add(const LatLng(-12.4655902, 130.8416637));
    polygon.add(const LatLng(-12.4656335, 130.8416195));

    polygonSet.add(Polygon(
        polygonId: const PolygonId('1'),
        points: polygon,
        strokeWidth: 1,
        fillColor: Colors.pink.withOpacity(0.3),
        strokeColor: Colors.red));

    polygon = [];
    polygon.add(const LatLng(-12.4655916, 130.8416625));
    polygon.add(const LatLng(-12.4656138, 130.8416866));
    polygon.add(const LatLng(-12.4655706, 130.8417309));
    polygon.add(const LatLng(-12.4655483, 130.8417067));
    polygon.add(const LatLng(-12.4655916, 130.8416625));

    polygonSet.add(Polygon(
        polygonId: const PolygonId('2'),
        points: polygon,
        strokeWidth: 2,
        fillColor: Colors.transparent,
        strokeColor: Colors.green));

    polygon = [];
    polygon.add(const LatLng(-12.4659569, 130.8412856));
    polygon.add(const LatLng(-12.4659791, 130.8413097));
    polygon.add(const LatLng(-12.4659359, 130.841354));
    polygon.add(const LatLng(-12.4659136, 130.8413298));
    polygon.add(const LatLng(-12.4659569, 130.8412856));

    polygonSet.add(Polygon(
        polygonId: const PolygonId('3'),
        points: polygon,
        strokeWidth: 2,
        fillColor: Colors.transparent,
        strokeColor: Colors.green));
    // 130.8413286 -12.465915, 130.8413527 -12.4659372, 130.841397 -12.465894, 130.8413728 -12.4658717, 130.8413286 -12.465915
    polygon = [];
    polygon.add(const LatLng(-12.465915, 130.8413286));
    polygon.add(const LatLng(-12.4659372, 130.8413527));
    polygon.add(const LatLng(-12.465894, 130.841397));
    polygon.add(const LatLng(-12.4658717, 130.8413728));
    polygon.add(const LatLng(-12.465915, 130.8413286));

    polygonSet.add(Polygon(
        polygonId: const PolygonId('4'),
        points: polygon,
        strokeWidth: 2,
        fillColor: Colors.transparent,
        strokeColor: Colors.green));





    return polygonSet;
  }

  _handleTap(LatLng tappedPoint) async {
    LatLng desLatLng = tappedPoint;
    setState(() {
      myMarker = [];
      myMarker.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          draggable: true,
          // icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          onDragEnd: (dragEndPosition){
            desLatLng = dragEndPosition;
          }
        )
      );
    });


    Destination  newDes = Destination();
    newDes.desAddress = await HelpersMethod.positionToAddress(desLatLng);
    newDes.desLat= desLatLng.latitude;
    newDes.desLng = desLatLng.longitude;
    Provider.of<DataHandle>(context, listen: false).updateDestination(newDes);
  }

  @override
  void initState()
  {
    super.initState();
    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polygons: myPolygon(),
          // mapType: MapType.hybrid,
          mapType: MapType.normal,
          myLocationEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //black theme google map
          },
          markers: Set.from(myMarker),
          onTap: _handleTap,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSize(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: searchBoxHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.only(
                //   topRight: Radius.circular(20),
                //   topLeft: Radius.circular(20),
                // ),
              ),
              child: Column(children: [
                Container(
                  height: 45,
                  width: double.infinity,
                  // color: const Color.fromRGBO(21, 34, 56, 1),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(21, 34, 56, 1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      topLeft: Radius.circular(4),
                    ),
                  ),
                  child: Row(children: const [
                    SizedBox(
                      width: 7.0,
                    ),
                    Icon(
                      Icons.add_location_alt_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      "Parking Bay Finder",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.none),
                    ),
                  ]),
                ),
                //     controller: tabController,
                //     controller: tabController,
                //     controller: tabController
                const SizedBox(
                  height: 15.0,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  child:
                      Row(textDirection: TextDirection.rtl, children: <Widget>[
                        Container(
                          // margin: const EdgeInsets.all(1),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(2.0)),
                                border: Border.all(
                                  color: Colors.black54, // Set border color
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                      blurRadius: 0,
                                      color: Colors.grey,
                                      offset: Offset(1, 1))
                                ] // Make rounded corner of border
                            ),
                            child: Material(
                              child: IconButton(
                                // icon: const Icon(Icons.location_on_outlined),
                                icon:
                                const Icon(Icons.location_searching_outlined),
                                iconSize: 25.0,
                                color: Colors.black54,
                                onPressed: locateUserPosition,
                              ),
                            )),
                        const SizedBox(
                          width: 30.0,
                        ),
                        Expanded(
                          child: Material(
                            child: TextField(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c)=>SearchPlacesScreen()));
                              },
                              readOnly: true,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                  hintText: Provider.of<DataHandle>(context).destination != null? (Provider.of<DataHandle>(context).destination!.desAddress!).substring(0,20) + "..." : "Where do you go?",
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 17.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  contentPadding:
                                  const EdgeInsets.only(left: 15.0, top: 15.0),
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.all(1),
                                    // height: 58,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.search_rounded),
                                      iconSize: 30.0,
                                      color: Colors.black54,
                                      onPressed: () {},
                                    ),
                                  )),
                            ),
                          ),
                        ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ],
    )
        // Scaffold(
        //   body: TabBarView(
        //     physics: const NeverScrollableScrollPhysics(),
        //     controller: tabController,
        //     children: const [
        //       HomeTabPage(),
        //       AccountTabPage(),
        //     ],
        //   ),
        //   bottomNavigationBar: BottomNavigationBar(
        //     items: const [
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.alt_route),
        //         label: "Parking",
        //       ),
        //
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.person),
        //         label: "Account",
        //       ),
        //
        //     ],
        //     unselectedItemColor: Colors.white54,
        //     selectedItemColor: Colors.white,
        //     backgroundColor: Colors.black,
        //     type: BottomNavigationBarType.fixed,
        //     selectedLabelStyle: const TextStyle(fontSize: 14),
        //     showUnselectedLabels: true,
        //     currentIndex: selectedIndex,
        //     onTap: onItemClicked,
        //   ),
        //
        // )
        ;
  }
}

