import 'dart:async';
import 'dart:ui';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:square_pants/pages/scedule_page.dart';
import 'package:square_pants/pages/statistics_page.dart';
import 'package:square_pants/service/notif_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.ref(); // Root reference
  String userId = 'Haikal'; // Store user ID
  bool switchState = false;
  Timer? _timer;

  int _currentIndex = 1; // Indeks awal untuk menunjukkan halaman Feed
  late PageController _pageController;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Listen for changes in authentication state
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        userId = user.uid;
        print('Logged in user ID: $userId');
        // Get data from RTDB based on user ID (if necessary)
        _fetchSwitchState();
      } else {
        print('No user signed in');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer in the dispose method
    _pageController.dispose();
    super.dispose();
  }

  void _fetchSwitchState() {
    databaseReference.child('switch_state').onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is bool) {
        setState(() {
          switchState = snapshot.value as bool;
        });

        if (switchState) {
          // If switchState is true, set a timer to turn it off after 2 seconds
          _timer?.cancel(); // Cancel any existing timer
          _timer = Timer(Duration(seconds: 2), () {
            _updateSwitchState(false);
          });
        }
      } else {
        print('No switch state found or invalid format');
      }
    }, onError: (error) {
      print('Error fetching switch state: $error');
    });
  }

  void _updateSwitchState(bool value) {
    databaseReference.child('switch_state').set(value).then((_) {
      print('Switch state updated to $value');
      setState(() {
        switchState = value;
      });
    }).catchError((error) {
      print('Error updating switch state: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff126B7E),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Statistics(),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackG.png'),
                fit: BoxFit.contain, // Adjust as needed
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          "Let's check",
                          style: TextStyle(
                              color: Color(0xffF9F9F9),
                              fontFamily: "poppins",
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "the fish feeder today.",
                        style: TextStyle(
                            color: Color(0xffF9F9F9),
                            fontFamily: "poppins",
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Stack(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 407,
                              width: 303,
                              decoration: BoxDecoration(
                                color: Color(0xffEFEFEF).withOpacity(0.7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(34)),
                                border: Border.all(
                                    width: 5,
                                    color: Color(0xffEFEFEF).withOpacity(0.3)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(34),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                  child: Container(
                                    color: Colors.transparent,
                                    // Konten Anda bisa ditaruh di sini
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 27,
                              left: 30,
                              child: Container(
                                width: 250,
                                height: 250,
                                child: Image.asset(
                                  'assets/images/Man.png',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 240,
                          child: Container(
                            width: 303,
                            height: 165,
                            decoration: BoxDecoration(
                              color: Color(0xffFFFFFF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(34)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 250,
                          left: 78,
                          child: Text(
                            "SQUAREPANTS",
                            style: TextStyle(
                                color: Color(0xff12171D),
                                fontFamily: "poppins",
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          top: 275,
                          left: 49,
                          child: Text(
                            "Toggle switch to feed your fish",
                            style: TextStyle(
                                color: Color(0xff12171D),
                                fontFamily: "poppins",
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Positioned(
                          top: 322,
                          left: 125,
                          child: Transform.scale(
                            scale: 2.3, // Mengatur faktor perbesaran
                            child: Switch(
                              value: switchState, // Nilai switch (true/false)
                              onChanged: (value) {
                                _updateSwitchState(value);
                                NotificationService.showNotif(
                                    "Feeding", "The Fish has been fed");
                              },
                              activeColor:
                                  Colors.white, // Warna ketika switch aktif
                              activeTrackColor: Color(
                                  0xFF25A1AE), // Warna track ketika switch aktif
                              inactiveThumbColor: Colors
                                  .white, // Warna thumb ketika switch tidak aktif
                              inactiveTrackColor: Color(0xff7A7B7C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Schecule(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color(0xff1A747D),
        color: Color(0xFFD9D9D9),
        iconPadding: 16,
        height: 70,
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        items: [
          CurvedNavigationBarItem(
            child: _currentIndex == 0
                ? Image.asset('assets/icons/cal2.png')
                : Image.asset('assets/icons/cal1.png'),
            label: 'Statistics',
            labelStyle: TextStyle(
              fontFamily: 'Poppins',
              color: _currentIndex == 0 ? Color(0xff25A1AE) : Color(0xff7A7B7C),
            ),
          ),
          CurvedNavigationBarItem(
            child: _currentIndex == 1
                ? Image.asset('assets/icons/home2.png')
                : Image.asset('assets/icons/home1.png'),
            label: 'Home',
            labelStyle: TextStyle(
              fontFamily: 'Poppins',
              color: _currentIndex == 1 ? Color(0xff25A1AE) : Color(0xff7A7B7C),
            ),
          ),
          CurvedNavigationBarItem(
            child: _currentIndex == 2
                ? Image.asset('assets/icons/clock2.png')
                : Image.asset('assets/icons/clock1.png'),
            label: 'Schedule',
            labelStyle: TextStyle(
              fontFamily: 'Poppins',
              color: _currentIndex == 2 ? Color(0xff25A1AE) : Color(0xff7A7B7C),
            ),
          ),
        ],
      ),
    );
  }
}
