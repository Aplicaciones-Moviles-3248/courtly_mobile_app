import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/http/api_exception.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/terms_and_conditions_dialog.dart';
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
  bool hasAcceptedTerms = false;
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
    if (!hasAcceptedTerms) {
      setState(() {
        successMessage = null;
        errorMessage =
            'Debes aceptar los Términos y Condiciones para crear tu cuenta.';
      });
      return;
    }

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

    // TODO: Persist terms acceptance in backend if a dedicated field is added later.
    try {
      final userId = await signUpUseCase.execute(email, password, [
        'ROLE_USER',
      ]);

      await signInUseCase.execute(email, password);

      await apiClient.post('/user-profiles', {
        'name': fullName,
        'email': email,
        'phone': phone,
        'imageUrl': 'https://i.pravatar.cc/300?img=12',
        'userId': userId,
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    } on ApiException catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.isConnectivity
            ? 'No se pudo conectar con el servidor. Puede estar iniciando, intenta de nuevo en unos segundos.'
            : 'No se pudo crear la cuenta. Revisa los datos o intenta con otro correo.';
      });
    } catch (error) {
      debugPrint('REGISTER ERROR: $error');

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
    //catch (_) {
    //setState(() {
    //isLoading = false;
    //errorMessage = 'No se pudo crear la cuenta. Intenta de nuevo.';
    //});
    //}
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
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo_courtly.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'MOCKUP ALINEADO AL BACKEND ACTUAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 22),
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
                  const SizedBox(height: 18),
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
                            hasAcceptedTerms: hasAcceptedTerms,
                            onTermsChanged: (value) {
                              setState(() {
                                hasAcceptedTerms = value;
                                if (value) {
                                  errorMessage = null;
                                }
                              });
                            },
                            onTermsTap: () async {
                              final accepted =
                                  await TermsAndConditionsDialog.show(context);

                              if (!mounted || accepted != true) return;

                              setState(() {
                                hasAcceptedTerms = true;
                                errorMessage = null;
                              });
                            },
                            onSubmit: signUpPlayer,
                          ),
                  ),
                  if (successMessage != null) ...[
                    const SizedBox(height: 14),
                    _MessageBox(message: successMessage!, isSuccess: true),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _MessageBox(message: errorMessage!, isSuccess: false),
                  ],
                  const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(4),
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo o usuario.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _AuthTextField(
            label: 'Contraseña',
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu contraseña.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
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
  final bool hasAcceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onSubmit;

  const _RegisterForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.isLoading,
    required this.hasAcceptedTerms,
    required this.onTermsChanged,
    required this.onTermsTap,
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
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Ingresa un nombre válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _AuthTextField(
            label: 'Correo',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (!text.contains('@') || !text.contains('.')) {
                return 'Ingresa un correo válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _AuthTextField(
            label: 'Teléfono',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.length < 7) {
                return 'Ingresa un teléfono válido.';
              }

              return null;
            },
          ),
          const SizedBox(height: 14),
          _AuthTextField(
            label: 'Contraseña',
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          const _AccountTypeBox(),
          const SizedBox(height: 14),
          _TermsAcceptanceCheckbox(
            isAccepted: hasAcceptedTerms,
            onChanged: onTermsChanged,
            onTermsTap: onTermsTap,
          ),
          const SizedBox(height: 18),
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

class _TermsAcceptanceCheckbox extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;

  const _TermsAcceptanceCheckbox({
    required this.isAccepted,
    required this.onChanged,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!isAccepted),
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 4, 10, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isAccepted,
              activeColor: AppColors.primary,
              onChanged: (value) => onChanged(value ?? false),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTermsTap,
                        child: const Text(
                          'Términos y Condiciones',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' de Courtly'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _AuthTextField({
    required this.label,
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF4F8FB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
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
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
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

  const _MessageBox({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
