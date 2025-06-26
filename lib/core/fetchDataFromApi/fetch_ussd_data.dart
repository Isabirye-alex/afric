import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../others/models/ussd_object_model.dart';
import '../../others/utilis/timer_utili.dart';

class FetchUssdData extends StatefulWidget {
  final http.Client? httpClient; // Optional client for testing

  const FetchUssdData({super.key, this.httpClient});

  @override
  State<FetchUssdData> createState() => _FetchUssdDataState();
}

class _FetchUssdDataState extends State<FetchUssdData> {
  String userInput = '';
  final TextEditingController inputController = TextEditingController();
  String sessionText = '';
  late Future<UssdViewObject> _futureResults;
  bool isLoading = true;

  http.Client get client => widget.httpClient ?? http.Client();

  @override
  void initState() {
    super.initState();
    sessionText = inputController.text.trim();
    Future.delayed(Duration.zero, () {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    setState(() {
      isLoading = true;
      _futureResults = sendUssdRequestWithResponse(sessionText);
    });

    _futureResults
        .then((_) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  Future<UssdViewObject> sendUssdRequestWithResponse(String userInput) async {
    try {
      final response = await client.post(
        Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
        body: <String, String>{
          'phoneNumber': '+256706432259',
          'text': userInput,
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
      throw Exception('Failed to connect. Error: $e');
    }
  }

  FutureBuilder<UssdViewObject> buildFutureBuilder() {
    final timerController = Get.put(TimerDialogController());
    timerController.startTimer();
    return FutureBuilder<UssdViewObject>(
      future: _futureResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(fontSize: 16, color: Colors.red),
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
                      visualDensity: const VisualDensity(vertical: -4),
                      title: Text(option, style: const TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: inputController,
                  decoration: const InputDecoration(),
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.only(left: 16, right: 24),
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
                          Get.back();
                          Get.snackbar(
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
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
                            _loadInitialData();
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
    return Padding(
      padding: EdgeInsets.zero,
      child: isLoading
          ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxHeight: 80, maxWidth: 80),
              child: const CircularProgressIndicator(),
            )
          : buildFutureBuilder(),
    );
  }
}
