import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const methodChannel = MethodChannel('com.bayunugroho404.method');
  static const pressureChannel = EventChannel('com.bayunugroho404.pressure');

  String _sensorAvailable = 'Unknown';
  double _pressureReading = 0.0;
  StreamSubscription? pressureSubscription;

  Future<void> _checkSensorAvailable() async {
    String sensorAvailable = '';
    try {
      var available = await methodChannel.invokeMethod('isSensorAvailable');
      setState(() {
        sensorAvailable = available ? 'Yes' : 'No';
      });
    } on PlatformException catch (e) {
      sensorAvailable = "Failed to get sensor available: '${e.message}'.";
    }

    setState(() {
      _sensorAvailable = sensorAvailable;
    });
  }

  _startPressureReading() {
    pressureSubscription = pressureChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        _pressureReading = event;
      });
    });
  }

  _stopPressureReading() {
    setState(() {
      _pressureReading = 0.0;
    });

    pressureSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sensor Available: $_sensorAvailable',
            ),
            ElevatedButton(
              onPressed: () => _checkSensorAvailable(),
              child: const Text('Check Sensor Available'),
            ),
            const SizedBox(height: 50.0,),
            Text(
              'Sensor Reading: $_pressureReading'
            ),
            ElevatedButton(
              onPressed: () => _startPressureReading(),
              child: const Text('Start Pressure Reading'),
            ),

            ElevatedButton(
              onPressed: () => _stopPressureReading(),
              child: const Text('Stop Pressure Reading'),
            ),

          ],
        ),
      ),
    );
  }
}
