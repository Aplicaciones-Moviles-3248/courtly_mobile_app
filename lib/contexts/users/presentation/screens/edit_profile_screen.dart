import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_my_user_profile_use_case.dart';
import '../../application/use_cases/update_user_profile_use_case.dart';
import '../../domain/entities/user_profile.dart';
import '../../infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../infrastructure/repositories/user_profile_repository_impl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();

  late final GetMyUserProfileUseCase getMyUserProfileUseCase;
  late final UpdateUserProfileUseCase updateUserProfileUseCase;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final imageUrlController = TextEditingController();

  UserProfile? currentProfile;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    final dataSource = UserProfileRemoteDataSource(apiClient);
    final repository = UserProfileRepositoryImpl(dataSource);

    getMyUserProfileUseCase = GetMyUserProfileUseCase(repository);
    updateUserProfileUseCase = UpdateUserProfileUseCase(repository);

    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await getMyUserProfileUseCase.execute();

      setState(() {
        currentProfile = profile;
        nameController.text = profile.name;
        emailController.text = profile.email;
        phoneController.text = profile.phone;
        imageUrlController.text = profile.imageUrl;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage =
        'No se pudo cargar el perfil. Verifica tu sesión o backend.';
        isLoading = false;
      });
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final profile = currentProfile;

    if (profile == null) {
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final updatedProfile = await updateUserProfileUseCase.execute(
        profile.copyWith(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          imageUrl: imageUrlController.text.trim(),
        ),
      );

      setState(() {
        currentProfile = updatedProfile;
        isSaving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      setState(() {
        isSaving = false;
        errorMessage =
        'No se pudo guardar el perfil. Revisa los datos ingresados.';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 4),
        body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null && currentProfile == null
                ? _ErrorView(
              message: errorMessage!,
              onRetry: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                loadProfile();
              },
            )
                : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERFIL Y DATOS PERSISTIDOS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Editar perfil',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ProfileSummaryCard(profile: currentProfile!),
                        const SizedBox(height: 18),
                        _FormCard(
                          nameController: nameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          imageUrlController: imageUrlController,
                          isSaving: isSaving,
                          onSave: saveProfile,
                        ),
                        const SizedBox(height: 18),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 18),
                        //const _RecentActivityCard(),
                        //const SizedBox(height: 18),
                        //_SessionCard(
                        //  onLogout: () async {
                        //    await LocalStorageService().clearSession();

                        //    if (!mounted) return;

                        //    ScaffoldMessenger.of(context).showSnackBar(
                        //      const SnackBar(
                        //        content: Text('Sesión cerrada.'),
                        //      ),
                        //    );
                        //  },
                        //),
                      ],
                    ),
                  ),
                ),

              ),
            ),
        ),
        );
        }
}

class _ProfileSummaryCard extends StatelessWidget {
  final UserProfile profile;

  const _ProfileSummaryCard({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = profile.imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'USUARIO',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                backgroundImage: hasImage
                    ? NetworkImage(profile.imageUrl)
                    : null,
                child: hasImage
                    ? null
                    : const Icon(
                  Icons.person,
                  color: AppColors.darkNavy,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileDataBox(label: 'EMAIL', value: profile.email),
          const SizedBox(height: 10),
          _ProfileDataBox(label: 'TELÉFONO', value: profile.phone),
          const SizedBox(height: 10),
          const _ProfileDataBox(label: 'ESPECIALIDAD', value: 'Jugador recreativo'),
          const SizedBox(height: 10),
          const _ProfileDataBox(label: 'EXPERIENCIA', value: 'No especificada'),
        ],
      ),
    );
  }
}

class _ProfileDataBox extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDataBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController imageUrlController;
  final bool isSaving;
  final VoidCallback onSave;

  const _FormCard({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.imageUrlController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actualizar datos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _ProfileTextField(
            label: 'Nombre',
            controller: nameController,
            validator: (value) {
              if (value == null || value
                  .trim()
                  .length < 3) {
                return 'Ingresa un nombre válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _ProfileTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (!text.contains('@') || !text.contains('.')) {
                return 'Ingresa un email válido.';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          _ProfileTextField(
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
          const SizedBox(height: 12),
          _ProfileTextField(
            label: 'URL de imagen',
            controller: imageUrlController,
            keyboardType: TextInputType.url,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isNotEmpty && !text.startsWith('http')) {
                return 'La URL debe iniciar con http o https.';
              }

              return null;
            },
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.validator,
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

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad reciente',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14),
          const _InfoItem(
            title: 'Persistencia del perfil',
            description: 'El backend guarda el perfil personal del usuario autenticado.',
          ),
          SizedBox(height: 10),
          _InfoItem(
            title: 'Imagen de perfil',
            description: 'La URL de imagen forma parte del flujo actual del backend.',
          ),
          SizedBox(height: 10),
          _InfoItem(
            title: 'Modelo del backend',
            description: 'La edición usa name, email, phone e imageUrl del contexto Users.',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String description;

  const _InfoItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final VoidCallback onLogout;

  const _SessionCard({
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sesión',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkNavy,
                foregroundColor: Colors.white,
              ),
              onPressed: onLogout,
              child: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}