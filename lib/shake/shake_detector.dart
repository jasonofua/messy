// File: lib/shake_detector.dart
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final Function onShake;
  final double shakeThresholdGravity = 2.7;
  final int shakeSlopTimeMs = 500;
  final int shakeCountResetTimeMs = 3000;

  int mShakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int mShakeCount = 0;

  ShakeDetector({required this.onShake}) {
    _startListening();
  }

  void _startListening() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double gX = event.x / 9.8;
      double gY = event.y / 9.8;
      double gZ = event.z / 9.8;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > shakeThresholdGravity) {
        int now = DateTime.now().millisecondsSinceEpoch;
        if (mShakeTimestamp + shakeSlopTimeMs > now) {
          return;
        }

        if (mShakeTimestamp + shakeCountResetTimeMs < now) {
          mShakeCount = 0;
        }

        mShakeTimestamp = now;
        mShakeCount++;

        onShake();
      }
    });
  }
}
