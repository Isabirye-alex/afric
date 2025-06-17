import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/changeNumber/change_number_controller.dart';
import '../../others/widgets/reusables/dotted_container.dart';
import '../../others/widgets/reusables/ready_widget.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Ready(),
                Row(
                  children: [
                    DottedContainer(
                      getIcon: Icons.perm_phone_msg_rounded,
                      getText: 'SMS',
                      screen: 0.40,
                      onTap: () => controller.checkUserStatus(),
                    ),
                    DottedContainer(
                      getIcon: Icons.dialpad,
                      getText: 'USSD',
                      screen: 0.40,
                      onTap: () => controller.checkUserStatus(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    DottedContainer(
                      getIcon: Icons.payments,
                      getText: 'PAYMENTS',
                      screen: 0.40,
                      onTap: () => controller.checkUserStatus(),
                    ),
                    DottedContainer(
                      getIcon: Icons.dialpad,
                      getText: 'AIRTIME',
                      screen: 0.40,
                      onTap: () => controller.checkUserStatus(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    DottedContainer(
                      getIcon: Icons.wifi_calling_3,
                      getText: 'VOICE',
                      screen: 0.9,
                      onTap: () => controller.checkUserStatus(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Ready extends StatelessWidget {
  const Ready({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.green[700]),
      child: ReadyWidget(),
    );
  }
}
