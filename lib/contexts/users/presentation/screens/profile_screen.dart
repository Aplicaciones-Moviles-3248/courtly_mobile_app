import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/http/api_exception.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_my_user_profile_use_case.dart';
import '../../domain/entities/user_profile.dart';
import '../../infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../infrastructure/repositories/user_profile_repository_impl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final GetMyUserProfileUseCase getMyUserProfileUseCase;

  UserProfile? profile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    final dataSource = UserProfileRemoteDataSource(apiClient);
    final repository = UserProfileRepositoryImpl(dataSource);

    getMyUserProfileUseCase = GetMyUserProfileUseCase(repository);

    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final loadedProfile = await getMyUserProfileUseCase.execute();

      setState(() {
        profile = loadedProfile;
        isLoading = false;
        errorMessage = null;
      });
    } on ApiException catch (error) {
      setState(() {
        isLoading = false;
        if (error.statusCode == 404) {
          // El usuario tiene sesión válida pero aún no ha creado su perfil.
          errorMessage = 'Aún no has completado tu perfil. Completa tus datos '
              'para continuar.';
        } else if (error.statusCode == 401 || error.statusCode == 403) {
          errorMessage = 'Tu sesión expiró. Inicia sesión nuevamente.';
        } else {
          errorMessage = 'No se pudo cargar el perfil. Verifica que el backend '
              'esté disponible e intenta de nuevo.';
        }
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se pudo cargar el perfil. Verifica tu sesión o backend.';
      });
    }
  }

  Future<void> logout() async {
    await LocalStorageService().clearSession();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.signIn,
          (route) => false,
    );
  }

  Future<void> goToEditProfile() async {
    await Navigator.pushNamed(context, AppRoutes.editProfile);

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 4),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
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
                    'Mi perfil',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ProfileSummaryCard(profile: profile!),
                  const SizedBox(height: 18),
                  _ActionCard(
                    onEditProfile: goToEditProfile,
                  ),
                  const SizedBox(height: 18),
                  const _StatsCard(),
                  const SizedBox(height: 18),
                  const _FriendsCard(),
                  const SizedBox(height: 18),
                  _SessionCard(onLogout: logout),
                ],
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
          const SizedBox(height: 8),
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
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x992EC4A6),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: hasImage
                      ? Image.network(
                    profile.imageUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    semanticLabel: 'Foto de perfil de ${profile.name}',
                  )
                      : Container(
                    width: 58,
                    height: 58,
                    color: Colors.white,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.darkNavy,
                      size: 32,
                    ),
                  ),
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
              color: Colors.white70,
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

class _ActionCard extends StatelessWidget {
  final VoidCallback onEditProfile;

  const _ActionCard({
    required this.onEditProfile,
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
          const SizedBox(height: 8),
          const Text(
            'Puedes modificar tu nombre, email, teléfono e imagen de perfil.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onEditProfile,
            child: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

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
            'Mis Estadísticas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: _StatItem(
                  icon: Icons.sports_tennis,
                  value: '12',
                  label: 'Partidos',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _StatItem(
                  icon: Icons.calendar_month,
                  value: '4',
                  label: 'Reservas',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.emoji_events, color: AppColors.primary, size: 24),
                      SizedBox(height: 8),
                      Text(
                        'Amateur',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nivel',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.all(22),
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
      ),
    );
  }
}

class _FriendsCard extends StatefulWidget {
  const _FriendsCard();

  @override
  State<_FriendsCard> createState() => _FriendsCardState();
}

class _FriendsCardState extends State<_FriendsCard> {
  List<String> _friends = [];
  final _friendNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _friendNameController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _friends = prefs.getStringList('my_friends') ?? ['Fabricio', 'Eduardo', 'Camilla', 'Pedro'];
    });
  }

  Future<void> _addFriend() async {
    final name = _friendNameController.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final updated = List<String>.from(_friends)..add(name);
    await prefs.setStringList('my_friends', updated);
    _friendNameController.clear();
    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            'Mis Amigos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (_friends.isEmpty)
            const Text(
              'Aún no has agregado amigos.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _friends.map((friend) {
                return Chip(
                  label: Text(friend),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  labelStyle: const TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
                  deleteIconColor: Colors.redAccent,
                  onDeleted: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final updated = List<String>.from(_friends)..remove(friend);
                    await prefs.setStringList('my_friends', updated);
                    _loadFriends();
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _friendNameController,
                  decoration: InputDecoration(
                    hintText: 'Nombre del amigo',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFFF4F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addFriend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(80, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Agregar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}