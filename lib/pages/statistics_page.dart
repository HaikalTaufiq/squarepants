// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:square_pants/graph/bar_graph.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.ref(); // Root reference
  String userId = 'Haikal'; // Store user ID
  double temperature = 0.0;
  double humidity = 0.0;
  List<FeedingData> feedingDataList = [];
  List<String> feedingKeys = [];

  StreamSubscription<DatabaseEvent>? _sensorDataSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for changes in authentication state
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        userId = user.uid;
        print('Logged in user ID: $userId');
        // Get data from RTDB based on user ID (if necessary)
        _startSensorDataListener();
      } else {
        print('No user signed in');
      }
    });
  }

  void _fetchFeedingsData() async {
    databaseReference.child('feedings').get().then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> feedings =
            Map<String, dynamic>.from(snapshot.value as Map);
        List<FeedingData> loadedFeedings = [];
        List<String> loadedKeys = []; // Initialize loadedKeys
        feedings.forEach((key, value) {
          String amount = value['amount'];
          String timestampString = value['timestamp'];
          DateTime timestamp =
              DateFormat('HH:mm, dd-MM-yyyy').parse(timestampString);
          loadedFeedings.add(FeedingData(amount: amount, timestamp: timestamp));
          loadedKeys.add(key); // Store the key
        });
        setState(() {
          feedingDataList = loadedFeedings;
          feedingKeys = loadedKeys; // Set loadedKeys to feedingKeys
        });
      }
    }).catchError((error) {
      print('Failed to fetch feedings data from database: $error');
    });
  }

  void _deleteFeedingData(int index) {
    if (index < 0 || index >= feedingKeys.length) {
      print('Invalid index: $index');
      return;
    }

    String key = feedingKeys[index];
    databaseReference.child('feedings').child(key).remove().then((_) {
      print('Feeding data removed from database');
      setState(() {
        feedingDataList.removeAt(index);
        feedingKeys.removeAt(index);
      });
    }).catchError((error) {
      print('Failed to remove feeding data from database: $error');
    });
  }

  void _startSensorDataListener() {
    // Subscribe to changes in 'sensor_data'
    _sensorDataSubscription =
        databaseReference.child('sensor_data').onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          temperature = _parseDouble(data['Temperature']); // Update temperature
          humidity = _parseDouble(data['Humidity']); // Update humidity
        });
        print('Sensor data: Temperature: $temperature°C, Humidity: $humidity%');
      } else {
        print('No sensor data found or invalid format');
      }
    }, onError: (error) {
      print('Error listening to sensor data: $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the subscription to avoid memory leaks
    _sensorDataSubscription?.cancel();
  }

  double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else {
      return 0.0;
    }
  }

  List<double> weeklySummary = [
    50.19,
    60.50,
    80.10,
    90.10,
    80.10,
    64.30,
    40.40,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff126B7E),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BackG.png'),
            fit: BoxFit.contain, // Adjust as needed
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                Transform.translate(
                  offset: Offset(25, 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's check",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "poppins",
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Your Statistics.',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "poppins",
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 5),
                      child: Stack(
                        children: [
                          Container(
                            height: 105,
                            width: 350,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 5, color: Color(0xffFFFFFF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                              color: Color(0xffFFFFFF),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18, left: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome!',
                                  style: TextStyle(
                                      color: Color(0xff12171D),
                                      fontFamily: "poppins",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "Lets check your",
                                  style: TextStyle(
                                      color: Color(0xff12171D),
                                      fontFamily: "poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Statistics",
                                  style: TextStyle(
                                      color: Color(0xff12171D),
                                      fontFamily: "poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -20,
                      right: 5,
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Image.asset('assets/images/cat.png'),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),

                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 20,
                                  ),
                                  child: Transform.scale(
                                    scale: 1.4,
                                    child:
                                        Image.asset('assets/images/temp.png'),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Temperatue : ",
                                        style: TextStyle(
                                            color: Color(0xff12171D),
                                            fontFamily: "poppins",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        "$temperature° ",
                                        style: TextStyle(
                                            color: Color(0xff12171D),
                                            fontFamily: "poppins",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Konten Anda bisa ditaruh di sini

                        width: 160,
                        height: 110,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                          ),

                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, top: 20, bottom: 5),
                                    child: Transform.scale(
                                      scale: 1.5,
                                      child:
                                          Image.asset('assets/images/g8.png'),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Humidity :",
                                          style: TextStyle(
                                              color: Color(0xff12171D),
                                              fontFamily: "poppins",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800),
                                        ),
                                        Text(
                                          "$humidity %",
                                          style: TextStyle(
                                              color: Color(0xff12171D),
                                              fontFamily: "poppins",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Konten Anda bisa ditaruh di sini

                          width: 160,
                          height: 110,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Container(
                    width: 400,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 12, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getFormattedDate(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors
                                      .black, // Changed from white to black for visibility
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _fetchFeedingsData(); // Fetch data before showing modal
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setModalState) {
                                          return Container(
                                            height: 500,
                                            width: double.infinity,
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Amount History",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount:
                                                        feedingDataList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final feeding =
                                                          feedingDataList[
                                                              index];
                                                      return ListTile(
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                      'HH:mm a, dd-MM-yyyy ')
                                                                  .format(feeding
                                                                      .timestamp),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'poppins',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .black),
                                                              onPressed: () {
                                                                _deleteFeedingData(
                                                                    index);
                                                                setModalState(
                                                                    () {
                                                                  feedingDataList
                                                                      .removeAt(
                                                                          index);
                                                                  feedingKeys
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        subtitle: Text(
                                                          feeding.amount,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'poppins'),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: Transform.rotate(
                                  angle: pi /
                                      2, // Rotate icon 90 degrees for down arrow
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors
                                        .black, // Changed from white to black for visibility
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 14), // Adjust padding as needed
                            child: MyBarGraph(
                              weeklySummary: weeklySummary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 135,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 25, bottom: 25),
                    children: [
                      Container(
                        width: 342,
                        decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            border:
                                Border.all(width: 5, color: Color(0xffFFFFFF)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(24))),
                        child: Transform.translate(
                          offset: Offset(25, 14),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                right: 45,
                                child: CircularPercentIndicator(
                                  radius: 35,
                                  lineWidth: 8,
                                  percent: 0.67,
                                  progressColor: Color(0xff12171D),
                                  backgroundColor: Color(0xffE4E4E4),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  center: Text(
                                    '67%',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff12171D),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total food leave this week",
                                      style: TextStyle(
                                        color: Color(0xff12171D),
                                        fontFamily: "poppins",
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '320 gram',
                                      style: TextStyle(
                                        color: Color(0xff12171D),
                                        fontFamily: "poppins",
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 27),
                        child: Container(
                          width: 342,
                          decoration: BoxDecoration(
                              color: Color(0xffFFFFFF),
                              border: Border.all(
                                  width: 5, color: Color(0xffFFFFFF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Transform.translate(
                            offset: Offset(25, 14),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  right: 45,
                                  child: CircularPercentIndicator(
                                    radius: 35,
                                    lineWidth: 8,
                                    percent: 0.67,
                                    progressColor: Color(0xff12171D),
                                    backgroundColor: Color(0xffE4E4E4),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    center: Text(
                                      '67%',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xff12171D),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total food leave this week",
                                        style: TextStyle(
                                          color: Color(0xff12171D),
                                          fontFamily: "poppins",
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        '320 gram',
                                        style: TextStyle(
                                          color: Color(0xff12171D),
                                          fontFamily: "poppins",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedingData {
  final String amount;
  final DateTime timestamp;

  FeedingData({required this.amount, required this.timestamp});
}

String getFormattedDate() {
  // Mendapatkan tanggal sekarang
  DateTime now = DateTime.now();

  // Mengubah tanggal menjadi format bulan dan tahun
  String bulan = DateFormat('MMMM').format(now);
  String tahun = DateFormat('yyyy').format(now);

  // Mengembalikan teks dengan format bulan dan tahun
  return '$bulan $tahun';
}
