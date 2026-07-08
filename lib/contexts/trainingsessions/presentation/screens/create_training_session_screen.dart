import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/http/api_exception.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../application/use_cases/create_training_session_use_case.dart';
import '../../application/use_cases/get_coach_availabilities_use_case.dart';
import '../../application/use_cases/get_current_player_profile_id_use_case.dart';
import '../../application/use_cases/get_training_courts_use_case.dart';
import '../../domain/entities/training_availability.dart';
import '../../domain/entities/training_court.dart';
import '../../infrastructure/datasources/training_session_remote_data_source.dart';
import '../../infrastructure/repositories/training_session_repository_impl.dart';

class CreateTrainingSessionScreen extends StatefulWidget {
  final String coachId;
  final String coachName;
  final String coachExpertise;
  final String coachPhone;

  const CreateTrainingSessionScreen({
    super.key,
    required this.coachId,
    required this.coachName,
    required this.coachExpertise,
    required this.coachPhone,
  });

  @override
  State<CreateTrainingSessionScreen> createState() =>
      _CreateTrainingSessionScreenState();
}

class _CreateTrainingSessionScreenState
    extends State<CreateTrainingSessionScreen> {
  late final GetCurrentPlayerProfileIdUseCase _getCurrentPlayerProfileIdUseCase;
  late final GetCoachAvailabilitiesUseCase _getCoachAvailabilitiesUseCase;
  late final GetTrainingCourtsUseCase _getTrainingCourtsUseCase;
  late final CreateTrainingSessionUseCase _createTrainingSessionUseCase;

  String? _playerId;
  List<TrainingAvailability> _availabilities = const [];
  List<TrainingCourt> _courts = const [];
  TrainingAvailability? _selectedAvailability;
  TrainingCourt? _selectedCourt;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient(LocalStorageService());
    final repository = TrainingSessionRepositoryImpl(
      TrainingSessionRemoteDataSource(apiClient),
    );

    _getCurrentPlayerProfileIdUseCase = GetCurrentPlayerProfileIdUseCase(
      repository,
    );
    _getCoachAvailabilitiesUseCase = GetCoachAvailabilitiesUseCase(repository);
    _getTrainingCourtsUseCase = GetTrainingCourtsUseCase(repository);
    _createTrainingSessionUseCase = CreateTrainingSessionUseCase(repository);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _getCurrentPlayerProfileIdUseCase.execute(),
        _getCoachAvailabilitiesUseCase.execute(widget.coachId),
        _getTrainingCourtsUseCase.execute(),
      ]);

      final filteredAvailabilities = (results[1] as List<TrainingAvailability>)
          .where((availability) => availability.endDateTime.isAfter(DateTime.now()))
          .toList();

      if (!mounted) return;
      setState(() {
        _playerId = results[0] as String;
        _availabilities = filteredAvailabilities;
        _courts = results[2] as List<TrainingCourt>;
        _selectedAvailability =
            filteredAvailabilities.isNotEmpty ? filteredAvailabilities.first : null;
        _selectedCourt = _courts.isNotEmpty ? _courts.first : null;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (error.statusCode == 404) {
          _errorMessage =
              'No se pudo identificar tu perfil de jugador. Inicia sesión con una cuenta que tenga user profile.';
        } else {
          _errorMessage =
              'No se pudo cargar la información para solicitar la sesión. Verifica tu conexión e intenta de nuevo.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'No se pudo cargar la información para solicitar la sesión. Intenta de nuevo.';
      });
    }
  }

  double get _estimatedPrice {
    final availability = _selectedAvailability;
    final court = _selectedCourt;
    if (availability == null || court == null) return 0;

    final minutes =
        availability.endDateTime.difference(availability.startDateTime).inMinutes;
    return (minutes / 60) * court.pricePerHour;
  }

  String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }

  String _formatDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  String _formatTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }

  String _friendlyBusinessError(ApiException error) {
    final message = error.message.toLowerCase();

    if (message.contains('availability is not open for reservation') ||
        message.contains('availability')) {
      return 'El horario seleccionado ya no está disponible.';
    }
    if (message.contains('already booked') ||
        message.contains('already assigned')) {
      return 'La cancha seleccionada ya no está disponible para ese horario.';
    }
    if (message.contains('forbidden') ||
        error.statusCode == 401 ||
        error.statusCode == 403) {
      return 'Tu sesión no tiene permisos para crear esta solicitud.';
    }

    return 'No se pudo registrar la solicitud. Verifica los datos e intenta de nuevo.';
  }

  Future<void> _submit() async {
    final playerId = _playerId;
    final availability = _selectedAvailability;
    final court = _selectedCourt;

    if (playerId == null || availability == null || court == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final session = await _createTrainingSessionUseCase.execute(
        playerId: playerId,
        coachId: widget.coachId,
        courtId: court.id,
        availabilityId: availability.id,
        startTime: availability.startDateTime,
        endTime: availability.endDateTime,
        price: _estimatedPrice,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            'Solicitud enviada',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Tu sesión fue registrada con estado ${session.status}.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _friendlyBusinessError(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'No se pudo registrar la solicitud. Intenta de nuevo en unos segundos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Solicitar sesión'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null &&
                    _availabilities.isEmpty &&
                    _courts.isEmpty
                ? _ErrorState(message: _errorMessage!, onRetry: _loadData)
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CoachHeroCard(
                          coachName: widget.coachName,
                          coachExpertise: widget.coachExpertise,
                          coachPhone: widget.coachPhone,
                        ),
                        const SizedBox(height: 24),
                        const _SectionHeader(
                          eyebrow: 'Horario',
                          title: 'Cuándo quieres entrenar',
                          subtitle:
                              'Elige uno de los espacios reales publicados por el entrenador.',
                        ),
                        const SizedBox(height: 12),
                        if (_availabilities.isEmpty)
                          const _EmptyCard(
                            message:
                                'Este entrenador no tiene horarios disponibles por ahora.',
                          )
                        else
                          ..._availabilities.map((availability) {
                            final isSelected =
                                _selectedAvailability?.id == availability.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _AvailabilityCard(
                                isSelected: isSelected,
                                dateLabel: _formatDate(
                                  availability.startDateTime,
                                ),
                                timeLabel:
                                    '${_formatTime(availability.startDateTime)} - ${_formatTime(availability.endDateTime)}',
                                onTap: () {
                                  setState(() {
                                    _selectedAvailability = availability;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            );
                          }),
                        const SizedBox(height: 18),
                        const _SectionHeader(
                          eyebrow: 'Cancha',
                          title: 'Dónde será la sesión',
                          subtitle:
                              'Selecciona la cancha que quieres enviar junto con tu solicitud.',
                        ),
                        const SizedBox(height: 12),
                        if (_courts.isEmpty)
                          const _EmptyCard(
                            message: 'No hay canchas disponibles para seleccionar.',
                          )
                        else
                          ..._courts.map((court) {
                            final isSelected = _selectedCourt?.id == court.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CourtCard(
                                isSelected: isSelected,
                                court: court,
                                onTap: () {
                                  setState(() {
                                    _selectedCourt = court;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            );
                          }),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : _BottomCheckoutBar(
              coachName: widget.coachName,
              availability: _selectedAvailability,
              court: _selectedCourt,
              estimatedPrice: _estimatedPrice,
              formatDateTime: _formatDateTime,
              isSubmitting: _isSubmitting,
              onSubmit: _selectedAvailability == null ||
                      _selectedCourt == null ||
                      _isSubmitting
                  ? null
                  : _submit,
            ),
    );
  }
}

class _CoachHeroCard extends StatelessWidget {
  final String coachName;
  final String coachExpertise;
  final String coachPhone;

  const _CoachHeroCard({
    required this.coachName,
    required this.coachExpertise,
    required this.coachPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF112B4A), Color(0xFF18385C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2211233F),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 112,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(coachName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SESIÓN PRIVADA',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coachName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coachExpertise,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.call_outlined,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          coachPhone.isEmpty ? 'Telefono no registrado' : coachPhone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0]).join();
    return initials.isEmpty ? 'C' : initials.toUpperCase();
  }

}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final bool isSelected;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback onTap;

  const _AvailabilityCard({
    required this.isSelected,
    required this.dateLabel,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAFBF7) : AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF4F8FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: isSelected ? AppColors.darkNavy : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Slot publicado por el coach',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final bool isSelected;
  final TrainingCourt court;
  final VoidCallback onTap;

  const _CourtCard({
    required this.isSelected,
    required this.court,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9E9) : AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFFE0B84D) : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFF4F8FB),
              ),
              clipBehavior: Clip.antiAlias,
              child: court.imageUrl.isNotEmpty
                  ? Image.network(
                      court.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.sports_tennis_rounded,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.sports_tennis_rounded,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${court.location} · ${court.type}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'S/ ${court.pricePerHour.toStringAsFixed(2)} por hora',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF9A6B00) : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCheckoutBar extends StatelessWidget {
  final String coachName;
  final TrainingAvailability? availability;
  final TrainingCourt? court;
  final double estimatedPrice;
  final String Function(DateTime value) formatDateTime;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  const _BottomCheckoutBar({
    required this.coachName,
    required this.availability,
    required this.court,
    required this.estimatedPrice,
    required this.formatDateTime,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Coach', value: coachName),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Cancha',
                  value: court?.name ?? 'Selecciona una cancha',
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Horario',
                  value: availability == null
                      ? 'Selecciona un horario'
                      : '${formatDateTime(availability!.startDateTime)} - ${formatDateTime(availability!.endDateTime).split(' ').last}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Costo estimado',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      estimatedPrice > 0
                          ? 'S/ ${estimatedPrice.toStringAsFixed(2)}'
                          : 'Pendiente',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirmar'),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 52),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
