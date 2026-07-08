import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/users/application/use_cases/get_my_user_profile_use_case.dart';
import 'package:courtly_mobile_app/contexts/users/domain/entities/user_profile.dart';
import 'package:courtly_mobile_app/contexts/users/domain/repositories/user_profile_repository.dart';
import 'package:courtly_mobile_app/contexts/users/infrastructure/models/user_profile_model.dart';

class _FakeUserProfileRepository implements UserProfileRepository {
  UserProfile? profile;
  Object? error;

  @override
  Future<UserProfile> getMyProfile() async {
    if (error != null) throw error!;
    return profile ??
        const UserProfile(
          id: 1,
          name: 'Fabricio',
          email: 'f@courtly.app',
          phone: '999',
          imageUrl: '',
        );
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async => profile;
}

void main() {
  group('UserProfileModel.fromJson', () {
    test('mapea todos los campos', () {
      final model = UserProfileModel.fromJson({
        'id': 4,
        'name': 'Ana',
        'email': 'ana@courtly.app',
        'phone': '555',
        'imageUrl': 'http://img',
        'userId': 12,
      });

      expect(model.id, 4);
      expect(model.name, 'Ana');
      expect(model.email, 'ana@courtly.app');
      expect(model.userId, 12);
    });

    test('aplica valores por defecto cuando faltan campos', () {
      final model = UserProfileModel.fromJson({'id': 2});

      expect(model.id, 2);
      expect(model.name, '');
      expect(model.email, '');
      expect(model.imageUrl, '');
      expect(model.userId, isNull);
    });

    test('toUpdateJson no incluye el id', () {
      const profile = UserProfileModel(
        id: 9,
        name: 'Ana',
        email: 'ana@courtly.app',
        phone: '555',
        imageUrl: '',
      );

      final json = profile.toUpdateJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['name'], 'Ana');
    });
  });

  group('GetMyUserProfileUseCase', () {
    test('retorna el perfil del repositorio', () async {
      final repo = _FakeUserProfileRepository()
        ..profile = const UserProfile(
          id: 7,
          name: 'Juan',
          email: 'j@courtly.app',
          phone: '111',
          imageUrl: '',
        );
      final useCase = GetMyUserProfileUseCase(repo);

      final result = await useCase.execute();

      expect(result.id, 7);
      expect(result.name, 'Juan');
    });

    test('propaga el error cuando el perfil no existe', () async {
      final repo = _FakeUserProfileRepository()..error = Exception('404');
      final useCase = GetMyUserProfileUseCase(repo);

      expect(() => useCase.execute(), throwsA(isA<Exception>()));
    });
  });
}
