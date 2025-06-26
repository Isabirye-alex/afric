
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
// This file is used to generate mock classes for testing purposes.
// It allows us to create mock HTTP clients for unit tests without making real network requests.

@GenerateMocks([http.Client])
// This annotation tells the code generator to create a mock class for http.Client.
// The generated mock class will be used in tests to simulate HTTP requests and responses.

void main() {}
