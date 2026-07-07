import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';

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
    final dateController = TextEditingController(text: DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0]);
    final notesController = TextEditingController(text: 'Deseo agendar una sesión privada.');

    final requested = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Solicitar a ${coach['name']}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  coach['expertise'],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha (YYYY-MM-DD)',
                    filled: true,
                    fillColor: const Color(0xFFF4F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notas / Mensaje',
                    filled: true,
                    fillColor: const Color(0xFFF4F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Resolve user profile id
                        final userJson = await apiClient.get('/user-profiles/me');
                        final playerId = userJson['id'];

                        // TODO(coaches): courtId/availabilityId están fijos porque
                        // aún no existe un endpoint de disponibilidad del coach.
                        // Cuando exista, reemplazar por la disponibilidad real
                        // seleccionada por el jugador.
                        final body = {
                          'playerId': playerId,
                          'coachId': coach['id'],
                          'courtId': 1,
                          'availabilityId': 1,
                          'startTime': '${dateController.text}T08:00:00',
                          'endTime': '${dateController.text}T09:00:00',
                          'price': 50.00
                        };

                        await apiClient.post('/training-sessions', body);
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } catch (e) {
                        // NO fingimos éxito: si la solicitud falla, el coach nunca
                        // la recibiría. Cerramos indicando el fallo para mostrar el
                        // error real al usuario.
                        if (ctx.mounted) Navigator.pop(ctx, false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Enviar Solicitud', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
