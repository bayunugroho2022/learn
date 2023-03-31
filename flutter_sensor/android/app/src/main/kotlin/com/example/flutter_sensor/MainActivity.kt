package com.example.flutter_sensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHODE_CAHANNEL_NAME = "com.bayunugroho404.method";
    private val PRESSURE_CAHANNEL_NAME = "com.bayunugroho404.pressure";

    private var methodChannel: MethodChannel? = null
    private lateinit var sensorManager: SensorManager
    private var pressureChannel : EventChannel? = null
    private var pressureStreamHandler : StreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        //setup channels
        setupChannels(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        teardownChannels()
        super.onDestroy()
    }

    private fun setupChannels(context: Context, messenger: BinaryMessenger) {
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        methodChannel = MethodChannel(messenger, METHODE_CAHANNEL_NAME)
        methodChannel!!.setMethodCallHandler { call, result ->
            if (call.method == "isSensorAvailable") {
                print(sensorManager.getSensorList(Sensor.TYPE_PRESSURE).isNotEmpty());
                result.success(sensorManager.getSensorList(Sensor.TYPE_PRESSURE).isNotEmpty())
            } else {
                result.notImplemented()
            }
        }

        pressureChannel = EventChannel(messenger, PRESSURE_CAHANNEL_NAME)
        pressureStreamHandler = StreamHandler(sensorManager, Sensor.TYPE_PRESSURE)
        pressureChannel!!.setStreamHandler(pressureStreamHandler)
    }

    private fun teardownChannels() {
        methodChannel!!.setMethodCallHandler(null)
        pressureChannel!!.setStreamHandler(null)
    }

}
