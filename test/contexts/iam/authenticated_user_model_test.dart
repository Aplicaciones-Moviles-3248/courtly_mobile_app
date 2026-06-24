import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/iam/infrastructure/models/authenticated_user_model.dart';

void main() {
  group('AuthenticatedUserModel.fromJson', () {
    test('mapea la respuesta real del backend de sign-in', () {
      final json = {
        'id': 2,
        'username': 'qa_juan',
        'token': 'eyJhbGciOiJIUzI1NiJ9.payload.signature',
      };

      final model = AuthenticatedUserModel.fromJson(json);

      expect(model.id, 2);
      expect(model.username, 'qa_juan');
      expect(model.token, 'eyJhbGciOiJIUzI1NiJ9.payload.signature');
    });

    test('usa valores por defecto cuando faltan campos', () {
      final model = AuthenticatedUserModel.fromJson({});

      expect(model.id, 0);
      expect(model.username, '');
      expect(model.token, '');
    });
  });
}
