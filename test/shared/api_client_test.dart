import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtly_mobile_app/shared/infrastructure/http/api_client.dart';
import 'package:courtly_mobile_app/shared/infrastructure/http/api_exception.dart';
import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient cold-start resilience', () {
    test('reintenta ante 503 (cold start) y termina devolviendo 200', () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        if (calls < 3) {
          return http.Response('waking up', 503);
        }
        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final client = ApiClient(
        LocalStorageService(),
        client: mock,
        timeout: const Duration(seconds: 5),
        maxRetries: 3,
      );

      final result = await client.get('/health');

      expect(calls, 3);
      expect(result['ok'], isTrue);
    });

    test('lanza ApiException de conectividad si el servidor sigue 503', () async {
      final mock = MockClient((request) async => http.Response('down', 503));

      final client = ApiClient(
        LocalStorageService(),
        client: mock,
        timeout: const Duration(seconds: 5),
        maxRetries: 1,
      );

      await expectLater(
        client.get('/health'),
        throwsA(isA<ApiException>().having((e) => e.isConnectivity, 'isConnectivity', isTrue)),
      );
    });

    test('reintenta ante timeout y termina en error de conectividad', () async {
      final mock = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return http.Response('late', 200);
      });

      final client = ApiClient(
        LocalStorageService(),
        client: mock,
        timeout: const Duration(milliseconds: 40),
        maxRetries: 1,
      );

      await expectLater(
        client.post('/authentication/sign-in', {'username': 'x', 'password': 'y'}),
        throwsA(isA<ApiException>().having((e) => e.isConnectivity, 'isConnectivity', isTrue)),
      );
    });

    test('no reintenta ante 401 y lo expone como ApiException', () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        return http.Response('unauthorized', 401);
      });

      final client = ApiClient(
        LocalStorageService(),
        client: mock,
        timeout: const Duration(seconds: 5),
        maxRetries: 3,
      );

      await expectLater(
        client.get('/payments'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
            .having((e) => e.isConnectivity, 'isConnectivity', isFalse)),
      );
      expect(calls, 1, reason: 'un 401 no debe reintentarse');
    });

    test('devuelve el cuerpo parseado en una respuesta 200', () async {
      final mock = MockClient((request) async =>
          http.Response(jsonEncode({'id': 7, 'token': 'abc'}), 200));

      final client = ApiClient(LocalStorageService(), client: mock);

      final result = await client.post('/authentication/sign-in', {});

      expect(result['id'], 7);
      expect(result['token'], 'abc');
    });
  });
}
