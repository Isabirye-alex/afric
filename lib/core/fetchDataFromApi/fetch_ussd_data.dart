//Imports for the necessary packages and files required to execute all functions in this file

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../others/models/ussd_object_model.dart';
import '../../others/utilis/timer_utili.dart';

/// Widget to fetch and display USSD-like menu options dynamically via API
/// This widget handles user input, sends requests to a backend service, and displays the results in a structured format.
/// It also manages session timeouts and allows users to navigate through options.
class FetchUssdData extends StatefulWidget {
  final http.Client? httpClient; // Optional HTTP client for testing
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

  /// Use the injected client if available (for testability), otherwise default(Real API request)
  /// This allows the widget to be tested with a mock HTTP client
  /// or to use the real HTTP client in production.
  http.Client get client => widget.httpClient ?? http.Client();

  @override
  void initState() {
    super.initState();
    sessionText = inputController.text.trim();

    // Defer loading after widget is built to engage the user as we fetch the data to display
    // This prevents blocking the UI thread and allows the widget to render first
    // Using Future.delayed with Duration.zero to ensure the widget is built before fetching data
    Future.delayed(Duration.zero, () {
      _loadInitialData();
    });
  }

  // Triggers the API call and updates UI state accordingly whenever called
  /// This method is responsible for initiating the data fetch process
  /// It sets the loading state, calls the API, and updates the UI based on the
  void _loadInitialData() {
    setState(() {
      isLoading = true;
      _futureResults = sendUssdRequestWithResponse(sessionText);
    });

    // Set loading to false after completion (or failure) to dismiss the circual progress indicator and display the formatted fetched data
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

  /// Sends the USSD request to the backend and parses the response which will either return data or a friendly error message
  /// This method handles the API request and response parsing
  /// It returns a Future that resolves to a UssdViewObject containing the parsed USSD data
  /// If the request fails, it throws an exception with an error message
  Future<UssdViewObject> sendUssdRequestWithResponse(String userInput) async {
    try {
      final response = await client.post(
        Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
        body: <String, String>{
          'phoneNumber': '+256706432259',
          'text': userInput,
        },
      );

      // Success status codes 
      // If the API responds with a success status code, parse the response body
      // and return a UssdViewObject containing the parsed data
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UssdViewObject.fromUssdString(
          response.body,
          phoneNumber: '+256706432259',
        );
      } else {
        // API responded with failure
        // If the API responds with an error status code, throw an exception
        // This will be caught in the FutureBuilder and displayed as an error message
        throw Exception('Failed to connect. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Connection or parsing error. Completely failed to connect to the provided API endpoint, maybe invalid or unsuppotted
      // If an error occurs during the request or parsing, throw an exception
      // This will be caught in the FutureBuilder and displayed as an error message
      throw Exception('Failed to connect. Error: $e');
    }
  }

  /// Builds the main content after data is fetched using a future builder to handle dynamic data being fetched
  /// 
  FutureBuilder<UssdViewObject> buildFutureBuilder() {
    final timerController = Get.put(TimerDialogController());
    timerController.startTimer(); // Start session timeout tracking to track how long the pop up menu has been open and either close it or allow the user continue with the current open session

    return FutureBuilder<UssdViewObject>(
      future: _futureResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // Still loading
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
              // Display list of options from the USSD response 

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
              // Text input for next USSD command

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: inputController,
                  decoration: const InputDecoration(),
                  maxLines: 1,
                ),
              ),
              // SEND and CANCEL buttons

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.only(left: 16, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(), // Close dialog
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final timerController =
                            Get.find<TimerDialogController>();

                        // Expired session handling
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

                        // Prepare and send next input
                        // This handles the user input and sends it to the backend
                        // It updates the session text and clears the input field
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
          // Empty fallback
          // If no data is available, display a message indicating no data found
          // This handles the case where the API returns no options or data
          return const Text('No data found.');
        }
      },
    );
  }

  /// Main widget builder
  /// This method builds the main widget tree for the FetchUssdData component
  /// It displays a loading indicator while data is being fetched and shows the results once available
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: isLoading
          ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxHeight: 80, maxWidth: 80),
              child: const CircularProgressIndicator(), // Show while loading
            )
          : buildFutureBuilder(), // Show data/error
    );
  }
}
