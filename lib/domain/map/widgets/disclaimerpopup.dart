import 'package:flutter/material.dart';
import 'package:location/location.dart';

Future<void> enableBackgroundLocation(BuildContext context, Location location) async {
  if(!await location.isBackgroundModeEnabled()) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Disclaimer'),
          content: const Text(
              'Please enable location in the background, so that students can track you, when your screen is off.'),
          actions: [
            ElevatedButton(
              onPressed: () async => {
                Navigator.of(context).pop(false),
                await location.enableBackgroundMode(enable: false)
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async => {
                Navigator.of(context).pop(true),
                await location.enableBackgroundMode(enable: true)
              },
              child: const Text('Enable'),
            )
          ],
        );
      });
  }
}
