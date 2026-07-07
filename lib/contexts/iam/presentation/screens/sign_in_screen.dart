import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/http/api_exception.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../application/use_cases/sign_in_use_case.dart';
import '../../application/use_cases/sign_up_use_case.dart';
import '../../infrastructure/datasources/authentication_remote_data_source.dart';
import '../../infrastructure/repositories/authentication_repository_impl.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final fullNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerPhoneController = TextEditingController();

  late final SignInUseCase signInUseCase;
  late final SignUpUseCase signUpUseCase;
  late final ApiClient apiClient;

  bool isLoginSelected = true;
  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    apiClient = ApiClient(localStorage);

    final dataSource = AuthenticationRemoteDataSource(apiClient);
    final repository = AuthenticationRepositoryImpl(
      dataSource: dataSource,
      localStorageService: localStorage,
    );

    signInUseCase = SignInUseCase(repository);
    signUpUseCase = SignUpUseCase(repository);

    loginEmailController.text = 'fabricio';
    loginPasswordController.text = '123456';
  }

  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      successMessage = null;
      errorMessage = null;
    });

    try {
      await signInUseCase.execute(
        loginEmailController.text.trim(),
        loginPasswordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    } on ApiException catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.isConnectivity
            ? 'No se pudo conectar con el servidor. Puede estar iniciando, intenta de nuevo en unos segundos.'
            : 'No se pudo iniciar sesión. Verifica tus credenciales.';
      });
    } catch (_) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se pudo iniciar sesión. Intenta de nuevo.';
      });
    }
  }

  Future<void> signUpPlayer() async {
    if (!signUpFormKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      successMessage = null;
      errorMessage = null;
    });

    final fullName = fullNameController.text.trim();
    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text.trim();
    final phone = registerPhoneController.text.trim();

    try {
      final userId = await signUpUseCase.execute(
        email,
        password,
        ['ROLE_USER'],
      );

      await signInUseCase.execute(email, password);

      await apiClient.post(
        '/user-profiles',
        {
          'name': fullName,
          'email': email,
          'phone': phone,
          'imageUrl': 'https://i.pravatar.cc/300?img=12',
          'userId': userId,
        },
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    } on ApiException catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.isConnectivity
            ? 'No se pudo conectar con el servidor. Puede estar iniciando, intenta de nuevo en unos segundos.'
            : 'No se pudo crear la cuenta. Revisa los datos o intenta con otro correo.';
      });
    } catch (_) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se pudo crear la cuenta. Intenta de nuevo.';
      });
    }
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    fullNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppShadows.shadowMd,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo_courtly.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  const Text(
                    'ACCESO PARA JUGADORES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  AppSpacing.gapSm,
                  const Text(
                    'Courtly para\njugadores y\nentrenadores',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  AppSpacing.gapLg,
                  _AuthTabs(
                    isLoginSelected: isLoginSelected,
                    onLoginTap: () {
                      setState(() {
                        isLoginSelected = true;
                        errorMessage = null;
                        successMessage = null;
                      });
                    },
                    onRegisterTap: () {
                      setState(() {
                        isLoginSelected = false;
                        errorMessage = null;
                        successMessage = null;
                      });
                    },
                  ),
                  AppSpacing.gapMd,
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isLoginSelected
                        ? _LoginForm(
                      key: const ValueKey('login'),
                      formKey: signInFormKey,
                      emailController: loginEmailController,
                      passwordController: loginPasswordController,
                      isLoading: isLoading,
                      onSubmit: signIn,
                    )
                        : _RegisterForm(
                      key: const ValueKey('register'),
                      formKey: signUpFormKey,
                      fullNameController: fullNameController,
                      emailController: registerEmailController,
                      passwordController: registerPasswordController,
                      phoneController: registerPhoneController,
                      isLoading: isLoading,
                      onSubmit: signUpPlayer,
                    ),
                  ),
                  if (successMessage != null) ...[
                    AppSpacing.gapMd,
                    _MessageBox(
                      message: successMessage!,
                      isSuccess: true,
                    ),
                  ],
                  if (errorMessage != null) ...[
                    AppSpacing.gapMd,
                    _MessageBox(
                      message: errorMessage!,
                      isSuccess: false,
                    ),
                  ],
                  AppSpacing.gapMd,
                  const Text(
                    'Demo: usa Swagger para crear jugadores, entrenadores o administradores según los roles reales del backend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const _AuthTabs({
    required this.isLoginSelected,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Iniciar sesión',
              isSelected: isLoginSelected,
              onTap: onLoginTap,
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Crear cuenta',
              isSelected: !isLoginSelected,
              onTap: onRegisterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected ? AppShadows.shadowSm : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _AuthTextField(
            label: 'Correo',
            controller: emailController,
            hintText: 'Ej. fabricio',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo o usuario.';
              }
              return null;
            },
          ),
          AppSpacing.gapMd,
          _AuthTextField(
            label: 'Contraseña',
            controller: passwordController,
            hintText: 'Ingresa tu contraseña',
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu contraseña.';
              }
              return null;
            },
          ),
          AppSpacing.gapLg,
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _RegisterForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _AuthTextField(
            label: 'Nombre completo',
            controller: fullNameController,
            hintText: 'Ej. Fabricio Pinedo',
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Ingresa un nombre válido.';
              }
              return null;
            },
          ),
          AppSpacing.gapMd,
          _AuthTextField(
            label: 'Correo',
            controller: emailController,
            hintText: 'Ej. fabricio@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (!text.contains('@') || !text.contains('.')) {
                return 'Ingresa un correo válido.';
              }
              return null;
            },
          ),
          AppSpacing.gapMd,
          _AuthTextField(
            label: 'Teléfono',
            controller: phoneController,
            hintText: 'Ej. 987654321',
            keyboardType: TextInputType.phone,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.length < 7) {
                return 'Ingresa un teléfono válido.';
              }

              return null;
            },
          ),
          AppSpacing.gapMd,
          _AuthTextField(
            label: 'Contraseña',
            controller: passwordController,
            hintText: 'Mínimo 6 caracteres',
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres.';
              }
              return null;
            },
          ),
          AppSpacing.gapMd,
          const _AccountTypeBox(),
          AppSpacing.gapLg,
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _AuthTextField({
    required this.label,
    this.hintText,
    required this.controller,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.gapXs,
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
          ), // Inherits from global Theme inputDecorationTheme
        ),
      ],
    );
  }
}

class _AccountTypeBox extends StatelessWidget {
  const _AccountTypeBox();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de cuenta',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.gapXs,
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Jugador',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _MessageBox({
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFE7FFF5) : const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSuccess ? AppColors.primary : Colors.redAccent,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSuccess ? AppColors.primaryDark : Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}