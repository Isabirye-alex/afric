import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class DottedContainer extends StatelessWidget {
  const DottedContainer({
    super.key,
    required this.getIcon,
    required this.getText,
    // this.screen,
    this.child,
    this.onTap,
  });

  final IconData getIcon;
  final String getText;
  // final double? screen;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Card(
      elevation: 10,
      child: Container(
        height: 150,
        // width: size.width * screen!,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(top: 12, left: 12, right: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(4.0, 4.0),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
        ),

        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              DottedBorder(
                options: CircularDottedBorderOptions(
                  dashPattern: [6, 3],
                  strokeWidth: 2,
                  color: Colors.deepOrangeAccent,
                  padding: EdgeInsets.all(8),
                ),
                child: Center(
                  child: Icon(getIcon, size: 70, color: Colors.orange[600]),
                ),
              ),
              SizedBox(height: 10),
              Text(getText, style: TextStyle(fontSize: 20)),
              // child ?? Container()
            ],
          ),
        ),
      ),
    );
  }
}
