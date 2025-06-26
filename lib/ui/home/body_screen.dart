import 'package:afri/others/practice/practice_barcode.dart';
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
                    Expanded(
                      flex: 5,
                      child: DottedContainer(
                        getIcon: Icons.perm_phone_msg_rounded,
                        getText: 'SMS',
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: DottedContainer(
                        getIcon: Icons.dialpad,
                        getText: 'USSD',
                        onTap: () => controller.checkUserStatus(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DottedContainer(
                        getIcon: Icons.payments,
                        getText: 'PAYMENTS',
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: DottedContainer(
                        getIcon: Icons.dialpad,
                        getText: 'AIRTIME',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DottedContainer(
                        getIcon: Icons.wifi_calling_3,
                        getText: 'VOICE',
                        onTap: () {},
                      ),
                    ),

                    Expanded(
                      flex: 5,
                      child: DottedContainer(
                        getIcon: Icons.qr_code_scanner_sharp,
                        getText: 'VERIFY ID',
                        onTap: () => Get.to(() => PracticeBarcode()),
                      ),
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
