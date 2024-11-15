import 'package:flutter/material.dart';


class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'This app allows you to recognize and compare faces. You can:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• Pick images for face recognition from your gallery.'),
            Text('• Capture known images using your camera.'),
            Text('• Compare faces to see if they match.'),
            SizedBox(height: 10),
            Text(
              'Purpose',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The purpose of this app is to provide face comparison functionality. '
                  'It uses machine learning to detect and compare facial features. '
                  'This can be useful for authentication, verification, and analysis.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
