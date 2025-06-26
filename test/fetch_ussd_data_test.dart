import 'package:afri/core/fetchDataFromApi/fetch_ussd_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'mocks/mock_http_client.mocks.dart';
import 'mocks/mock_timer.dart';

void main() {
  // Ensures all bindings are initialized before tests run
  // This is necessary for GetX to work properly in widget tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ViewWidget', () {
    late MockClient mockClient;

    setUp(() {
      // Create a new mock HTTP client before each test
      // This allows us to simulate API calls without hitting a real server
      // We use MockClient from the generated mocks file
      mockClient = MockClient();

      // Register or replace the mock Timer controller in GetX
      // This allows us to control the timer behavior in tests
      // If the controller is already registered, we replace it to ensure a fresh instance
      if (Get.isRegistered<MockTimerDialogController>()) {
        Get.replace<MockTimerDialogController>(MockTimerDialogController());
      } else {
        Get.put<MockTimerDialogController>(MockTimerDialogController());
      }
    });

    tearDown(() {
      // Clean up GetX and mock state after each test
      // This ensures no state leaks between tests
      Get.delete<MockTimerDialogController>();
      Get.reset();
      reset(mockClient);
    });

    testWidgets('shows loading indicator and then options', (
      WidgetTester tester,
    ) async {
      // Mock response simulating successful USSD menu load 
      // This response should match the expected format of the USSD API
      // The response starts with "CON" to indicate a continuation of the USSD session
      const mockResponse = '''
CON Welcome to MCash
1. Deposit
2. Funds Transfer
3. Agent Withdraw
4. Buy Airtime
5. Payments
6. Loans
7. Financial Services
8. My Account
9. Mcash Pay
10. Services
''';

      // Mock the API call to return the above response
      // This simulates the backend returning a valid USSD menu response
      // The URI should match the one used in the FetchUssdData widget
      when(
        mockClient.post(
          Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

      // Build the widget tree using GetMaterialApp and inject the mock client
      // This allows us to test the FetchUssdData widget in isolation
      // The widget will use the mock client to fetch USSD data instead of hitting a real API
      // We wrap it in a Scaffold to provide the necessary context for the widget
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: FetchUssdData(httpClient: mockClient)),
        ),
      );

      // Ensure the loading indicator appears first
      // This confirms that the widget is in a loading state while fetching data
      // The CircularProgressIndicator should be visible until the API call completes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the FutureBuilder to finish and data to render
      // This allows the widget to process the mock API response and update the UI
      // We use pumpAndSettle to wait for all animations and state changes to complete
      await tester.pumpAndSettle();

      // Check that all expected text options from the mock response appear
      // This confirms that the USSD menu options were parsed and displayed correctly

      expect(find.text('CON Welcome to MCash'), findsOneWidget);
      expect(find.text('1. Deposit'), findsOneWidget);
      expect(find.text('2. Funds Transfer'), findsOneWidget);
      expect(find.text('3. Agent Withdraw'), findsOneWidget);
      expect(find.text('4. Buy Airtime'), findsOneWidget);
      expect(find.text('5. Payments'), findsOneWidget);
      expect(find.text('6. Loans'), findsOneWidget);
      expect(find.text('7. Financial Services'), findsOneWidget);
      expect(find.text('8. My Account'), findsOneWidget);
      expect(find.text('9. Mcash Pay'), findsOneWidget);
      expect(find.text('10. Services'), findsOneWidget);
    });

    testWidgets('shows error when API fails', (WidgetTester tester) async {
      // Mock a failed API response (HTTP 500)
      // This simulates a server error when trying to fetch USSD data
      // The error response should trigger the error handling logic in the widget
      when(
        mockClient.post(
          Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      // Build widget with failing mock client
      // This will use the mock client to simulate a failed API call
      // The widget will attempt to fetch USSD data and should handle the error gracefully
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: FetchUssdData(httpClient: mockClient)),
        ),
      );

      // Confirm the loading spinner shows first
      // This indicates that the widget is in a loading state while fetching data
      // The CircularProgressIndicator should be visible until the API call completes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for error text to show
      // This allows the widget to process the failed API response and update the UI
      // We use pumpAndSettle to wait for all animations and state changes to complete
      await tester.pumpAndSettle();

      // Check for specific error message output
      // This confirms that the widget displays a user-friendly error message when the API call fails
      expect(find.byWidgetPredicate(errorTextPredicate), findsOneWidget);
    });
  });
}

/// Helper predicate to identify error messages
/// This function checks if a widget is a Text widget containing specific error text
/// It is used to verify that the widget displays the correct error message when the API call fails
bool errorTextPredicate(Widget widget) {
  return widget is Text &&
      widget.data != null &&
      widget.data!.contains('Error:') &&
      widget.data!.contains('Failed to connect');
}
