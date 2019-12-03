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
import 'drawn_hand.dart';

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
  var _temperatureRange = '';
  var _condition = '';
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
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
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


    if(Theme.of(context).brightness == Brightness.light){
      _clockFaceName = 'assets/img/light_clock_face.png';
    } else {
      _clockFaceName = 'assets/img/dark_clock_face.png';
    }

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFFFFFFFF),
            // Minute hand.
            highlightColor: Color(0xFFFBFBFB),
            // Second hand.
            accentColor: Color(0xFFFF060A),
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFFFFFFF),
            highlightColor: Color(0xFFC0C0C0),
            accentColor: Color(0xFFFF0202),
            backgroundColor: Color(0xFF000000),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Flexible(
              flex: 1,
              child: Text('mountain view')
            ),

            Flexible(
              flex: 2,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) => Stack(
                  children: [

                    //Clock face
                    Center(child: Image.asset(_clockFaceName)),

                    //Seconds hand
                    ContainerHand(
                      color: Colors.transparent,
                      size: 0.5,
                      angleRadians: _now.second * radiansPerTick,
                      child: Transform.translate(
                        offset: Offset(0.0, - constraints.maxHeight * 0.38),
                        child: Container(
                          width: constraints.maxHeight * 0.008,
                          height: constraints.maxHeight * 0.76,
                          decoration: BoxDecoration(
                            color: customTheme.accentColor,
                            borderRadius: BorderRadius.circular(constraints.maxHeight),
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
                        offset: Offset(0.0, - constraints.maxHeight * 0.25),
                        child: Container(
                          width: constraints.maxHeight * 0.03,
                          height: constraints.maxHeight * 0.5,
                          decoration: BoxDecoration(
                            color: customTheme.highlightColor,
                            borderRadius: BorderRadius.circular(constraints.maxHeight * 0.01),
                          ),
                        ),
                      ),  
                    ),


                    //Hours hand
                    ContainerHand(
                      color: Colors.transparent,
                      size: 0.5,
                      angleRadians: radiansPerHour  * (_now.hour + (_now.minute / 60)),
                      child: Transform.translate(
                        offset: Offset(0.0, - constraints.maxHeight * 0.12),
                        child: Container(
                          width: constraints.maxHeight * 0.08,
                          height: constraints.maxHeight * 0.3,
                          decoration: BoxDecoration(
                            color: customTheme.primaryColor,
                            borderRadius: BorderRadius.circular(constraints.maxHeight * 0.02),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 38.0,
                              )
                            ]
                          ),
                        ),
                      ),     
                    ),



                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
