import 'package:afri/core/fetchDataFromApi/fetch_data_class.dart';
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


    testWidgets('shows loading indicator and then options', (
      WidgetTester tester,
    ) async {
      const mockResponse =
          '{"text": "Welcome", "options": ["1. Check Balance", "2. Send Money"]}';

      // Mock HTTP response
      when(
        mockClient.post(
          Uri.parse('https://newtest.mcash.ug/wallet/api/client/ussd'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: ViewWidget())),
      );

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for FutureBuilder

      expect(find.text('1. Check Balance'), findsOneWidget);
      expect(find.text('2. Send Money'), findsOneWidget);
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
          home: Scaffold(
            body: ViewWidget(httpClient: mockClient)),
        ),
      );


      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
