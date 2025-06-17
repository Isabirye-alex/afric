import 'package:afri/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/changeNumber/change_number_controller.dart';

void main() {
  Get.put(UserController());
  runApp(Africa());
}

class Africa extends StatelessWidget {
  const Africa({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: HomeScreen(),
    );
  }
}
