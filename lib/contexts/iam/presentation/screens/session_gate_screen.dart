import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../users/presentation/screens/profile_screen.dart';
import '../../application/use_cases/check_session_use_case.dart';
import '../../infrastructure/datasources/authentication_remote_data_source.dart';
import '../../infrastructure/repositories/authentication_repository_impl.dart';
import 'sign_in_screen.dart';

/// SessionGate
///
/// Pantalla raíz que decide el destino inicial de la app según el estado de la
/// sesión: si existe un token persistido entra directo al perfil; si no, muestra
/// la pantalla de autenticación.
class SessionGateScreen extends StatefulWidget {
  const SessionGateScreen({super.key});

  @override
  State<SessionGateScreen> createState() => _SessionGateScreenState();
}

class _SessionGateScreenState extends State<SessionGateScreen> {
  late final CheckSessionUseCase checkSessionUseCase;
  late final Future<bool> sessionFuture;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    final dataSource = AuthenticationRemoteDataSource(apiClient);
    final repository = AuthenticationRepositoryImpl(
      dataSource: dataSource,
      localStorageService: localStorage,
    );

    checkSessionUseCase = CheckSessionUseCase(repository);
    sessionFuture = checkSessionUseCase.execute();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSession = snapshot.data ?? false;

        return hasSession ? const ProfileScreen() : const SignInScreen();
      },
    );
  }
}
