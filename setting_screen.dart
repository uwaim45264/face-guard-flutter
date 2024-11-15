import 'package:flutter/material.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSlideTransition = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Transition Type:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Slide Transition'),
              value: _isSlideTransition,
              onChanged: (value) {
                setState(() {
                  _isSlideTransition = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Fade Transition'),
              value: !_isSlideTransition,
              onChanged: (value) {
                setState(() {
                  _isSlideTransition = !value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
