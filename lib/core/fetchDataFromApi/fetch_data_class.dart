import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../others/models/ussd_object_model.dart';
import '../../others/utilis/timer_utili.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});
  @override
  State<ViewWidget> createState() => _ViewWidgetState();
}

class _ViewWidgetState extends State<ViewWidget> {
  String userInput = '';
  final TextEditingController inputController = TextEditingController();
  String sessionText = '';
  late Future<UssdViewObject> _futureResults;
  @override
  void initState() {
    super.initState();
    sessionText = inputController.text.trim();
    _futureResults = sendUssdRequestWithResponse(sessionText);
  }

  Future<UssdViewObject> sendUssdRequestWithResponse(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
        body: <String, String>{
          'phoneNumber': '+256706432259',
          'text': sessionText,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return UssdViewObject.fromUssdString(
          response.body,
          phoneNumber: '+256706432259',
        );
      } else {
        throw Exception('Failed to connect. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error:$e');
    }
  }

  FutureBuilder<UssdViewObject> buildFutureBuilder() {
    final timerController = Get.put(TimerDialogController());
    timerController.startTimer();
    return FutureBuilder<UssdViewObject>(
      future: _futureResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(fontSize: 16, color: Colors.red),
          );
        } else if (snapshot.hasData) {
          final ussdObject = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: ussdObject.options?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (ussdObject.options == null ||
                        index >= ussdObject.options!.length) {
                      return const ListTile(
                        title: Text('No options available'),
                      );
                    }
                    final option = ussdObject.options![index];
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      title: Text(option, style: TextStyle(fontSize: 16)),
                      onTap: () {},
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: TextField(
                  controller: inputController,
                  decoration: InputDecoration(),
                  maxLines: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                margin: EdgeInsets.only(left: 16, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final timerController =
                            Get.find<TimerDialogController>();

                        if (!timerController.isWithinAllowedTime()) {
                          Get.back(); // Close dialog (optional)
                          Get.snackbar(
                            snackPosition: SnackPosition.BOTTOM,
                            duration: Duration(seconds: 2),
                            "Session expired",
                            "Please repeat the operation.",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        setState(() {
                          final currentInput = inputController.text.trim();
                          if (currentInput.isNotEmpty) {
                            sessionText = sessionText.isEmpty
                                ? currentInput
                                : '$sessionText*$currentInput';
                            _futureResults = sendUssdRequestWithResponse(
                              sessionText,
                            );
                            inputController.clear();
                            // print('Full sessionText: $sessionText');
                          }
                        });
                      },
                      child: const Text(
                        'SEND',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return const Text('No data found.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.zero, child: buildFutureBuilder());
  }
}
