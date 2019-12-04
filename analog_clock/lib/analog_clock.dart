// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'container_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  String _clockFaceName = 'assets/img/light_clock_face.png';

  var _now = DateTime.now();
  var _temperature = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hms().format(DateTime.now());
    ThemeData customTheme = ThemeData();
    BoxShadow hourHandBoxShadow = BoxShadow();

    if (Theme.of(context).brightness == Brightness.light) {
      _clockFaceName = 'assets/img/light_clock_face.png';
      customTheme = Theme.of(context).copyWith(
          primaryColor: Color(0xFFFFFFFF), //hour hand
          highlightColor: Color(0xFFFBFBFB), //minute hand
          accentColor: Color(0xFFFF060A), //seconds hnd
          backgroundColor: Color(0xFFFFFFFF),
          textTheme: TextTheme(
            display1: TextStyle(
              fontFamily: 'Alata',
              fontWeight: FontWeight.w400,
              color: Color(0xFF505050),
            ),
            body1: TextStyle(
              fontFamily: 'Alata',
              fontWeight: FontWeight.w400,
              color: Color(0xFF808080),
            ),
          ));
      hourHandBoxShadow = BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 38.0,
      );
    } else {
      _clockFaceName = 'assets/img/dark_clock_face.png';
      customTheme = Theme.of(context).copyWith(
          primaryColor: Color(0xFFFFFFFF),
          highlightColor: Color(0xFFC0C0C0),
          accentColor: Color(0xFFFF0202),
          backgroundColor: Color(0xFF000000),
          textTheme: TextTheme(
            display1: TextStyle(
              fontFamily: 'Alata',
              fontWeight: FontWeight.w400,
              color: Color(0xFFE0E0E0),
            ),
            body1: TextStyle(
              fontFamily: 'Alata',
              fontWeight: FontWeight.w400,
              color: Color(0xFF969696),
            ),
          ));
      hourHandBoxShadow = BoxShadow(
        color: Colors.black.withOpacity(0.72),
        blurRadius: 30.0,
      );
    }

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _location,
                            style: customTheme.textTheme.display1.copyWith(
                                fontSize: constraints.maxHeight * 0.04),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            DateFormat('MMMM d, y').format(_now),
                            style: customTheme.textTheme.body1.copyWith(
                                fontSize: constraints.maxHeight * 0.024),
                          ),
                        ),
                        Text(
                          _temperature,
                          style: customTheme.textTheme.body1.copyWith(
                              fontSize: constraints.maxHeight * 0.024),
                        ),
                      ],
                    ),
                  )),
              Flexible(
                flex: 2,
                child: Stack(
                  children: [
                    //Clock face
                    Center(child: Image.asset(_clockFaceName)),

                    //Seconds hand
                    ContainerHand(
                      color: Colors.transparent,
                      size: 0.5,
                      angleRadians: _now.second * radiansPerTick,
                      child: Transform.translate(
                        offset: Offset(0.0, -constraints.maxHeight * 0.38),
                        child: Container(
                          width: constraints.maxHeight * 0.008,
                          height: constraints.maxHeight * 0.76,
                          decoration: BoxDecoration(
                            color: customTheme.accentColor,
                            borderRadius:
                                BorderRadius.circular(constraints.maxHeight),
                          ),
                        ),
                      ),
                    ),

                    //Minutes hand
                    ContainerHand(
                      color: Colors.transparent,
                      size: 0.5,
                      angleRadians: _now.minute * radiansPerTick,
                      child: Transform.translate(
                        offset: Offset(0.0, -constraints.maxHeight * 0.25),
                        child: Container(
                          width: constraints.maxHeight * 0.03,
                          height: constraints.maxHeight * 0.5,
                          decoration: BoxDecoration(
                            color: customTheme.highlightColor,
                            borderRadius: BorderRadius.circular(
                                constraints.maxHeight * 0.01),
                          ),
                        ),
                      ),
                    ),

                    //Hours hand
                    ContainerHand(
                      color: Colors.transparent,
                      size: 0.5,
                      angleRadians:
                          radiansPerHour * (_now.hour + (_now.minute / 60)),
                      child: Transform.translate(
                        offset: Offset(0.0, -constraints.maxHeight * 0.12),
                        child: Container(
                          width: constraints.maxHeight * 0.068,
                          height: constraints.maxHeight * 0.28,
                          decoration: BoxDecoration(
                              color: customTheme.primaryColor,
                              borderRadius: BorderRadius.circular(
                                  constraints.maxHeight * 0.02),
                              boxShadow: [hourHandBoxShadow]),
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
    );
  }
}
