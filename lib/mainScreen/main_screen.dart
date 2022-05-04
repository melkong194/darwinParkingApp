import 'dart:async';
import 'package:darwin_parking/mainScreen/search_places_screen.dart';
import 'package:darwin_parking/models/Destination.dart';
import 'package:darwin_parking/models/countParkingBay.dart';
import 'package:darwin_parking/models/user_location.dart';
import 'package:darwin_parking/services/dataHandle.dart';
import 'package:darwin_parking/services/helpers_http.dart';
import 'package:darwin_parking/services/helpers_method.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:darwin_parking/Data/mockdata.dart';

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
  final LatLng centralPointA = const LatLng(-12.4658003,130.8402635);
  final LatLng centralPointB = const LatLng(-12.4604642,130.8383165);
  final LatLng centralPointC = const LatLng(-12.455383,130.8299683);
  final LatLng centralPointD = const LatLng(-12.454758,130.8363408);
  double searchBoxHeight = 230;
  Position? userPosition;
  var geoLocator = Geolocator();
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  List<Marker> myMarker = [];
  LocationPermission? _locationPermission;
  String readAddress = "";
  List<List<double>> slotList = [];
  List<int> noSlots = [0,0,0,0,0,0];
  //[availaible car, total car, avaible disable, total disable, available motor, total motor]
  String carText = "N/A";
  String disableText = "N/A";
  String motorText = "N/A";


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
    CameraPosition cameraPosition = CameraPosition(target:latlngPosition, zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    UserLocation  newLocation = UserLocation();
    newLocation.userAddress = await HelpersMethod.positionToAddress(latlngPosition);
    newLocation.userLat= latlngPosition.latitude;
    newLocation.userLng = latlngPosition.longitude;
    Provider.of<DataHandle>(context, listen: false).updateUserLocation(newLocation);
  }

  directPaths()
  {

  }

  updateZone(opt) {
    switch (opt){
      case 1:
        slotList = LocationData.zoneA;
        CameraPosition cameraPosition = CameraPosition(target:centralPointA, zoom: 16);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        break;
      case 2:
        slotList = LocationData.zoneB;
        CameraPosition cameraPosition = CameraPosition(target:centralPointB, zoom: 16);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        break;
      case 3:
        slotList = LocationData.zoneC;
        CameraPosition cameraPosition = CameraPosition(target:centralPointC, zoom: 16);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        break;
      case 4:
        slotList = LocationData.zoneD;
        CameraPosition cameraPosition = CameraPosition(target:centralPointD, zoom: 16);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        break;
    }
    myPolygon();
  }

  Set<Polygon> myPolygon() {
    Set<Polygon> polygonSet = {};
    noSlots = [0,0,0,0,0,0];
    setState(() {
      for (var i = 0; i < slotList.length; i++) {
        var el = slotList[i];
        List<LatLng> polygon = [];
        polygon.add(LatLng(el[2], el[1]));
        polygon.add(LatLng(el[4], el[3]));
        polygon.add(LatLng(el[6], el[5]));
        polygon.add(LatLng(el[8], el[7]));
        polygon.add(LatLng(el[10], el[9]));

        Color slotColor = Colors.transparent;


        switch(el[11].toInt()){
          case 1:
          // for car
            slotColor = Colors.green;
            if(el[0]==0) {
              noSlots[0] = noSlots[0] + 1;
            }
            noSlots[1] = noSlots[1] + 1;
            break;

          case 2:
          //for disables
            if(el[0]==0) {
              noSlots[2] = noSlots[2] + 1;
            }
            noSlots[3] = noSlots[3] + 1;
            slotColor = Colors.deepOrange;
            break;

          case 3:
          //for blue
            slotColor = Colors.blue;
            if(el[0]==0) {
              noSlots[4] = noSlots[4] + 1;
            }
            noSlots[5] = noSlots[5] + 1;
            break;
        }
        polygonSet.add(Polygon(
          polygonId: PolygonId(i.toString()),
          points: polygon,
          strokeWidth: 2,
          fillColor: el[0] == 1 ? slotColor.withOpacity(0.6) : Colors.transparent,
          strokeColor: slotColor,
        ));
      }

      carText = noSlots[0].toString() + "/" + noSlots[1].toString();
      disableText = noSlots[2].toString() + "/" + noSlots[3].toString();
      motorText = noSlots[4].toString() + "/" + noSlots[5].toString();
    });

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
    return Scaffold(
      key: sKey,
      drawer: Container(
          width: 150,
          height: 255,
          color: Colors.white,
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(left: 10.0, bottom: 280.0),
          child: Drawer(
            elevation: 16.0,
            child: ListView(
              children: [
                //drawer body
                GestureDetector(
                  onTap: ()
                  {
                    updateZone(1);
                  },
                  child: const ListTile(
                    leading: Text(
                      "___",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      "Zone A",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: ()
                  {
                    updateZone(2);
                  },
                  child: const ListTile(
                    leading: Text(
                      "___",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      "Zone B",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: ()
                  {
                    updateZone(3);
                  },
                  child: const ListTile(
                    leading: Text(
                      "___",
                      style: TextStyle(
                        color: Colors.purpleAccent,
                      ),
                    ),
                    title: Text(
                      "Zone C",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: ()
                  {
                    updateZone(4);
                  },
                  child: const ListTile(
                    leading: Text(
                      "___",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      "Zone D",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
      body: Stack(
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
                    height: 40,
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
                              var response = Navigator.push(context, MaterialPageRoute(builder: (c)=>SearchPlacesScreen()));
                                if(response == "obtainedDestination"){
                                  //draw route or do something here
                                  print("AAAA");
                                  print(Provider.of<DataHandle>(context).destination!.desAddress);
                                }
                              },
                            readOnly: true,
                            // textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: Provider.of<DataHandle>(context).destination != null? (Provider.of<DataHandle>(context).destination!.desAddress!).substring(0,20) + "..." : "Where do you go?",
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              // contentPadding:
                              // const EdgeInsets.only(left: 15.0, top: 15.0),
                              // suffixIcon: Container(
                              //   margin: const EdgeInsets.all(1),
                              //   // height: 58,
                              //   width: 50,
                              //   decoration: const BoxDecoration(
                              //     border: Border(
                              //       left: BorderSide(
                              //         color: Colors.black54,
                              //       ),
                              //     ),
                              //   ),
                              //   child: IconButton(
                              //     icon: const Icon(Icons.search_rounded),
                              //     iconSize: 30.0,
                              //     color: Colors.black54,
                              //     onPressed: () {},
                              //   ),
                              // )
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ElevatedButton(
                    child: const Text(
                      "Direction Path",
                    ),
                    onPressed: directPaths,
                    style: ElevatedButton.styleFrom(
                        primary: const Color.fromRGBO(255, 87, 51, 1),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Container(
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child:(
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget> [
                          // Text("car:",
                          //     style: TextStyle(
                          //       fontSize: 18.0,
                          //       color: Colors.green,
                          //       fontWeight: FontWeight.bold,
                          //       letterSpacing: -1.0,
                          //       wordSpacing: 5.0,),
                          // ),
                          const Icon(
                            Icons.local_taxi,
                            color: Colors.green,
                          ),
                          Text(carText),
                          const Spacer(),
                          const Icon(
                            Icons.wheelchair_pickup,
                            color: Colors.deepOrange,
                          ),
                          Text(disableText),
                          const Spacer(),
                          const Icon(
                            Icons.motorcycle_outlined,
                            color: Colors.blue,
                          ),
                          Text(motorText),
                        ]
                      )
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 14,
            child: GestureDetector(
              onTap: ()
              {
                sKey.currentState!.openDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.menu,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );

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

  Future<void> drawPolyLineFromOriginToDestination() async
  {
    var originPosition = Provider.of<DataHandle>(context, listen: false).userLocation;
    var destinationPosition = Provider.of<DataHandle>(context, listen: false).destination;

    var originLatLng = LatLng(originPosition!.userLat!, originPosition.userLng!);
    var destinationLatLng = LatLng(destinationPosition!.desLat!, destinationPosition.desLng!);

    var directionDetailsInfo = await HelpersMethod.obtainDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

  }
}