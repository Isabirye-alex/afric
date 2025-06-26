import 'package:afri/core/fetchDataFromApi/fetch_ussd_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'mocks/mock_http_client.mocks.dart';
import 'mocks/mock_timer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ViewWidget', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      Get.put<MockTimerDialogController>(MockTimerDialogController());
    });

    tearDown(() {
      Get.reset();
      reset(mockClient);
    });

    testWidgets('shows loading indicator and then options', (
      WidgetTester tester,
    ) async {
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

      when(
        mockClient.post(
          Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: FetchUssdData(httpClient: mockClient)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
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
      when(
        mockClient.post(
          Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: FetchUssdData(httpClient: mockClient)),
        ),
      );

      // Wait for the loading indicator to appear first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the future to complete and error to be displayed
      await tester.pumpAndSettle();

      // Look for error text that contains "Failed to connect"
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.contains('Error:') &&
              widget.data!.contains('Failed to connect'),
        ),
        findsOneWidget,
      );
    });
  });
}
