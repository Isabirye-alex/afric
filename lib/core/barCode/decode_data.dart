import 'package:flutter/material.dart';

class DecodedDataScreen extends StatelessWidget {
  final Map<String, String> decodedData;

  const DecodedDataScreen({super.key, required this.decodedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decoded Barcode Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: decodedData.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(entry.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}
