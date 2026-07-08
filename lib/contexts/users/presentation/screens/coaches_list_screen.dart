import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../../trainingsessions/presentation/screens/create_training_session_screen.dart';

class CoachesListScreen extends StatefulWidget {
  const CoachesListScreen({super.key});

  @override
  State<CoachesListScreen> createState() => _CoachesListScreenState();
}

class _CoachesListScreenState extends State<CoachesListScreen> {
  late final ApiClient apiClient;
  List<dynamic> _coaches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient(LocalStorageService());
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await apiClient.getList('/coaches');
      setState(() {
        _coaches = list;
        _isLoading = false;
      });
    } catch (e) {
      // No fabricamos coaches falsos: solicitar un entrenamiento a un coach
      // inventado nunca llegaría al backend. Mostramos un estado de error real
      // para que el usuario pueda reintentar.
      setState(() {
        _coaches = [];
        _isLoading = false;
        _errorMessage = 'No se pudo cargar la lista de coaches.\n'
            'Verifica tu conexión e intenta de nuevo.';
      });
    }
  }

  Future<void> _requestTraining(Map<String, dynamic> coach) async {
    final requested = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateTrainingSessionScreen(
          coachId: '${coach['id'] ?? ''}',
          coachName: coach['name']?.toString() ?? 'Entrenador',
          coachExpertise: coach['expertise']?.toString() ?? '',
          coachPhone: coach['phone']?.toString() ?? '',
        ),
      ),
    );

    if (!mounted) return;
    if (requested == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Solicitud enviada con éxito a ${coach['name']}!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (requested == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar la solicitud. '
              'Verifica tu conexión e intenta de nuevo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Ocurrió un error.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadCoaches,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.darkNavy),
              label: const Text('Reintentar', style: TextStyle(color: AppColors.darkNavy)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No hay entrenadores disponibles por ahora.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ENTRENADORES DISPONIBLES',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Coaches',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: _errorMessage != null
                        ? _buildErrorState()
                        : _coaches.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      itemCount: _coaches.length,
                      itemBuilder: (ctx, index) {
                        final coach = _coaches[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          color: AppColors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                  child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coach['name'] ?? 'Entrenador',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        coach['expertise'] ?? 'Tenis',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Teléfono: ${coach['phone']}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                                  onPressed: () => _requestTraining(coach),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
