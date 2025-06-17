import 'package:flutter/material.dart';

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
    required this.text1,
    required this.text2,
  });
  final Color color;
  final IconData icon;
  final String text;
  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 50,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(4.0, 4.0),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          // border: Border.all()
        ),
        height: 220,
        width: MediaQuery.of(context).size.width * 0.9,
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: color,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Icon(icon, size: 50, color: Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
            Center(child: Text(text, style: TextStyle(fontSize: 20))),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.school, color: Colors.lightBlueAccent),
                    ),
                    Text(text1),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Text(text2),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
