import 'dart:async';
import 'package:darwin_parking/mainScreen/main_screen.dart';
import 'package:flutter/material.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer()
  {
    Timer(const Duration(seconds: 3), () async
    {
      //send user to main screen
      Navigator.push(context, MaterialPageRoute(builder: (c)=>MainScreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context)
  {
    return Material(
      child: Container(
        color: const Color.fromRGBO(21, 34, 56, 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Image(image: AssetImage('./images/logo.png')),

              SizedBox(height: 10,),

              Text(
                "Darwin Parking App",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

