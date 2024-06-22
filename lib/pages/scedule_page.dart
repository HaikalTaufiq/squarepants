// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:square_pants/service/timepicker.dart';

class Schecule extends StatefulWidget {
  const Schecule({super.key});

  @override
  State<Schecule> createState() => _ScheculeState();
}

class _ScheculeState extends State<Schecule> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<TimeOfDay> scheduleTimes = [];
  List<String> scheduleKeys = []; // To store the keys

  int _selectedMinute = 0;
  int _selectedHour = 0;
  String _selectedTimeFormat = "AM";

  @override
  void initState() {
    super.initState();
    _fetchScheduleTimes();
  }

  void _fetchScheduleTimes() {
    databaseReference.child('schedules').get().then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> schedules =
            Map<String, dynamic>.from(snapshot.value as Map);
        List<TimeOfDay> loadedTimes = [];
        List<String> loadedKeys = []; // Initialize loadedKeys
        schedules.forEach((key, value) {
          String timeString = value['time'];
          List<String> parts = timeString.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          loadedTimes.add(TimeOfDay(hour: hour, minute: minute));
          loadedKeys.add(key); // Store the key
        });
        setState(() {
          scheduleTimes = loadedTimes;
          scheduleKeys = loadedKeys; // Set loadedKeys to scheduleKeys
        });
      }
    }).catchError((error) {
      print('Failed to fetch schedule times from database: $error');
    });
  }

  void _deleteTimeFromDatabase(int index) {
    if (index < 0 || index >= scheduleKeys.length) {
      print('Invalid index: $index');
      return;
    }

    String key = scheduleKeys[index];
    databaseReference.child('schedules').child(key).remove().then((_) {
      print('Time removed from database');
      setState(() {
        scheduleTimes.removeAt(index);
        scheduleKeys.removeAt(index);
      });
    }).catchError((error) {
      print('Failed to remove time from database: $error');
    });
  }

  void _updateTimeInDatabase(int index, TimeOfDay newTime) {
    if (index < 0 || index >= scheduleKeys.length) {
      print('Invalid index: $index');
      return;
    }

    String key = scheduleKeys[index];
    final String formattedTime =
        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

    databaseReference
        .child('schedules')
        .child(key)
        .update({'time': formattedTime}).then((_) {
      print('Time updated in database: $formattedTime');
      setState(() {
        scheduleTimes[index] = newTime;
      });
    }).catchError((error) {
      print('Failed to update time in database: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff126B7E),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BackG.png'),
              fit: BoxFit.contain, // Adjust as needed
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(-60, 25),
                child: Column(
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
                      'your fish feeding.',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "poppins",
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 0),
                    child: Stack(
                      children: [
                        Container(
                          height: 115,
                          width: 350,
                          decoration: BoxDecoration(
                              color: Color(0xffFFFFFF),
                              border: Border.all(
                                  color: Color(0xffFFFFFF), width: 5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25, left: 28),
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
                                "Let's schedule your ",
                                style: TextStyle(
                                    color: Color(0xff12171D),
                                    fontFamily: "poppins",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                'Fish Feeder',
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
                    top: -5,
                    right: 5,
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Image.asset('assets/images/cat.png'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: scheduleTimes.length,
                  itemBuilder: (context, index) {
                    var scheduleTime = scheduleTimes[index].format(context);
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter setModalState) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 25),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          color: Color(0xffFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 7),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Transform.translate(
                                  offset: Offset(9, 0),
                                  child: Row(
                                    children: [
                                      Transform.translate(
                                        offset: Offset(-2, 0),
                                        child: Icon(
                                          Icons.label,
                                          color: Color(0xff12171D),
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        'Feed',
                                        style: TextStyle(
                                          color: Color(0xff12171D),
                                          fontFamily: "poppins",
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    onChanged: (bool value) {
                                      // Implement the logic to update the switch status in the database
                                    },
                                    value: true,
                                    activeColor: Color(0xff12171D),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: Color(0xffF9F9F9),
                                  useRootNavigator: true,
                                  context: context,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          padding: EdgeInsets.all(0),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10),
                                              ListTile(
                                                title: Center(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 3,
                                                        width: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xff12171D),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(30),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'Edit Time',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff212121),
                                                          fontFamily: "poppins",
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Feeding Schedule',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff5F5F5F),
                                                          fontFamily: "poppins",
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              NumberPickerWidget(
                                                hour: _selectedHour,
                                                minute: _selectedMinute,
                                                timeFormat: _selectedTimeFormat,
                                                onHourChanged: (value) {
                                                  setModalState(() {
                                                    _selectedHour = value;
                                                  });
                                                },
                                                onMinuteChanged: (value) {
                                                  setModalState(() {
                                                    _selectedMinute = value;
                                                  });
                                                },
                                                onTimeFormatChanged: (value) {
                                                  setModalState(() {
                                                    _selectedTimeFormat = value;
                                                  });
                                                },
                                              ),
                                              FloatingActionButton.extended(
                                                backgroundColor:
                                                    Color(0xFF25A1AE),
                                                onPressed: () {
                                                  TimeOfDay updatedTime =
                                                      TimeOfDay(
                                                    hour: _selectedHour,
                                                    minute: _selectedMinute,
                                                  );
                                                  _updateTimeInDatabase(
                                                      index, updatedTime);
                                                  Navigator.pop(context);
                                                },
                                                label: Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    fontFamily: "poppins",
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
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
                              child: Transform.translate(
                                offset: Offset(0, -10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        scheduleTime,
                                        style: TextStyle(
                                          color: Color(0xff12171D),
                                          fontFamily: 'poppins',
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Color(0xff12171D),
                                        onPressed: () {
                                          _deleteTimeFromDatabase(index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: MaterialButton(
                  onPressed: () => _showNumberPicker(context),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNumberPicker(BuildContext context) async {
    int initialMinute = TimeOfDay.now().minute;

    int? pickedHour = await showModalBottomSheet<int>(
      backgroundColor: Color(0xffF9F9F9),
      useRootNavigator: true,
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    title: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Set Time',
                            style: TextStyle(
                              color: Color.fromARGB(255, 33, 33, 33),
                              fontFamily: "poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Feeding Schedule',
                            style: TextStyle(
                                color: Color.fromARGB(255, 95, 95, 95),
                                fontFamily: "poppins",
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  NumberPickerWidget(
                    hour: _selectedHour,
                    minute: _selectedMinute,
                    timeFormat: _selectedTimeFormat,
                    onHourChanged: (value) {
                      setModalState(() {
                        _selectedHour = value;
                      });
                    },
                    onMinuteChanged: (value) {
                      setModalState(() {
                        _selectedMinute = value;
                      });
                    },
                    onTimeFormatChanged: (value) {
                      setModalState(() {
                        _selectedTimeFormat = value;
                      });
                    },
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xFF25A1AE),
                    onPressed: () {
                      TimeOfDay pickedTime = TimeOfDay(
                        hour: _selectedHour,
                        minute: _selectedMinute,
                      );
                      setState(() {
                        scheduleTimes.add(pickedTime);
                      });
                      _saveTimeToDatabase(pickedTime);
                      Navigator.pop(context);
                    },
                    label: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: "poppins",
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );

    if (pickedHour != null) {
      TimeOfDay pickedTime = TimeOfDay(hour: pickedHour, minute: initialMinute);
      setState(() {
        scheduleTimes.add(pickedTime);
      });
      _saveTimeToDatabase(pickedTime);
    }
  }

  void _saveTimeToDatabase(TimeOfDay time) {
    final String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    databaseReference
        .child('schedules')
        .push()
        .set({'time': formattedTime}).then((_) {
      print('Time saved to database: $formattedTime');
    }).catchError((error) {
      print('Failed to save time to database: $error');
    });
  }
}
