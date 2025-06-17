import 'package:flutter/material.dart';

class DecodedInfoScreen extends StatelessWidget {
  final Map<String, String> decodedData;

  const DecodedInfoScreen({super.key, required this.decodedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decoded Barcode Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan Time: 03:00 PM EAT, Tuesday, June 17, 2025', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ...decodedData.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${entry.key}:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Flexible(child: Text(entry.value, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to scanner screen
              },
              child: Text('Back to Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}