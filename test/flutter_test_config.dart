import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// flutter_secure_storage has no in-memory test implementation, so any test
/// that touches LocalStorageService/ApiClient hits its platform channel
/// directly and throws MissingPluginException. This mocks that channel with
/// a simple in-memory store, reset before every test, so tests that persist
/// a session in one test don't leak it into the next.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'write':
          final key = call.arguments['key'] as String;
          final value = call.arguments['value'] as String?;
          if (value == null) {
            store.remove(key);
          } else {
            store[key] = value;
          }
          return null;
        case 'read':
          return store[call.arguments['key'] as String];
        case 'delete':
          store.remove(call.arguments['key'] as String);
          return null;
        case 'readAll':
          return store;
        case 'deleteAll':
          store.clear();
          return null;
        case 'containsKey':
          return store.containsKey(call.arguments['key'] as String);
        default:
          return null;
      }
    });
  });

  await testMain();
}
