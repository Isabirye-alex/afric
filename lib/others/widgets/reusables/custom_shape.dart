import 'package:flutter/material.dart';

class CustomShape extends StatelessWidget {
  const CustomShape({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        decoration: BoxDecoration(color: Colors.orange[500]),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.56,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Takes minimum space needed
                  children: [
                    Text(
                      'Developer Documentation',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Explore our Tutorials, Code Samples, API Reference, SDKs and other resources to help you start building with Africa\'s Talking.',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/ninja.png',
                  width: 200,
                  height: 140,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(
      0,
      size.height - 50,
    ); // Start at bottom-left, slightly above the bottom
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 50, // Control point for the curve (middle, below bottom)
      size.width,
      size.height - 50, // End at bottom-right
    );
    path.lineTo(size.width, 0); // Complete the path to top-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
