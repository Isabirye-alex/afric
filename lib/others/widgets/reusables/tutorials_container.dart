import 'package:flutter/material.dart';

class TutorialsContainer extends StatelessWidget {
  const TutorialsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.orange),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: Text(
              'Interactive Tutorials',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 6),
            child: Text(
              'Learn how to build with our APIs at your own pace through interactive tutorials.',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
          SizedBox(height: 15),
          TutorialsCard(
            icon: Icons.sms,
            text1: 'Messaging 101 - Sending an SMS',
            text2: 'Learn More',
          ),
          SizedBox(height: 15),
          TutorialsCard(
            icon: Icons.speaker_phone_outlined,
            text1: 'Airtime 101 - Sending Airtime',
            text2: 'Learn More',
          ),
          SizedBox(
            height: 50,
            child: Container(decoration: BoxDecoration(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

class TutorialsCard extends StatelessWidget {
  const TutorialsCard({
    super.key,
    required this.icon,
    required this.text1,
    required this.text2,
  });
  final IconData icon;
  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: EdgeInsets.all(14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(30),
            child: Icon(icon, size: 60, color: Colors.purple),
          ),
          SizedBox(height: 20),
          Divider(),
          Text(text1, style: TextStyle(fontSize: 20, color: Colors.grey)),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text2, style: TextStyle(fontSize: 20, color: Colors.green)),
              Icon(Icons.arrow_right_alt_outlined, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}
