import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../../matches/application/use_cases/approve_match_join_request_use_case.dart';
import '../../../matches/application/use_cases/create_match_join_request_use_case.dart';
import '../../../matches/application/use_cases/get_all_matches_use_case.dart';
import '../../../matches/application/use_cases/get_join_requests_for_match_use_case.dart';
import '../../../matches/application/use_cases/get_match_join_request_use_case.dart';
import '../../../matches/domain/entities/match.dart';
import '../../../matches/domain/entities/match_join_request.dart';
import '../../../matches/infrastructure/datasources/match_remote_data_source.dart';
import '../../../matches/infrastructure/repositories/match_repository_impl.dart';
import '../../../notifications/application/use_cases/get_my_notifications_use_case.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../../notifications/infrastructure/datasources/notification_remote_data_source.dart';
import '../../../notifications/infrastructure/repositories/notification_repository_impl.dart';
import '../../application/use_cases/get_my_user_profile_use_case.dart';
import '../../domain/entities/user_profile.dart';
import '../../infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../infrastructure/repositories/user_profile_repository_impl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GetAllMatchesUseCase _getAllMatchesUseCase;
  late final GetMyUserProfileUseCase _getMyUserProfileUseCase;
  late final GetMyNotificationsUseCase _getMyNotificationsUseCase;
  late final CreateMatchJoinRequestUseCase _createJoinRequestUseCase;
  late final GetMatchJoinRequestUseCase _getJoinRequestUseCase;
  late final GetJoinRequestsForMatchUseCase _getJoinRequestsForMatchUseCase;
  late final ApproveMatchJoinRequestUseCase _approveJoinRequestUseCase;

  List<Match> _feedMatches = [];
  List<AppNotification> _notifications = [];
  Map<String, List<MatchJoinRequest>> _pendingApprovalsByMatchId = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);

    final matchDataSource = MatchRemoteDataSource(apiClient);
    final matchRepository = MatchRepositoryImpl(matchDataSource);
    _getAllMatchesUseCase = GetAllMatchesUseCase(matchRepository);
    _createJoinRequestUseCase = CreateMatchJoinRequestUseCase(matchRepository);
    _getJoinRequestUseCase = GetMatchJoinRequestUseCase(matchRepository);
    _getJoinRequestsForMatchUseCase = GetJoinRequestsForMatchUseCase(matchRepository);
    _approveJoinRequestUseCase = ApproveMatchJoinRequestUseCase(matchRepository);

    final userDataSource = UserProfileRemoteDataSource(apiClient);
    final userRepository = UserProfileRepositoryImpl(userDataSource);
    _getMyUserProfileUseCase = GetMyUserProfileUseCase(userRepository);

    final notificationDataSource = NotificationRemoteDataSource(apiClient);
    final notificationRepository = NotificationRepositoryImpl(notificationDataSource);
    _getMyNotificationsUseCase = GetMyNotificationsUseCase(notificationRepository);

    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final matches = await _getAllMatchesUseCase.execute();

      UserProfile? user;
      try {
        user = await _getMyUserProfileUseCase.execute();
      } catch (_) {
        user = null;
      }

      List<AppNotification> notifications = [];
      try {
        notifications = await _getMyNotificationsUseCase.execute();
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (_) {
        notifications = [];
      }

      var feedMatches = <Match>[];
      var pendingApprovals = <String, List<MatchJoinRequest>>{};

      if (user != null) {
        final myId = user.id;
        feedMatches = matches.where((match) {
          final isOwnOrJoined = match.createdBy.id == myId ||
              match.participants.any((participant) => participant.id == myId);
          return !isOwnOrJoined && match.currentPlayers < match.maxPlayers;
        }).toList();

        final myMatches = matches
            .where((match) => match.participants.any((participant) => participant.id == myId))
            .toList();

        for (final match in myMatches) {
          try {
            final requests = await _getJoinRequestsForMatchUseCase.execute(match.id);
            final needsMyApproval = requests
                .where((request) => request.isPending && !request.approvedByUserIds.contains(myId))
                .toList();
            if (needsMyApproval.isNotEmpty) {
              pendingApprovals[match.id] = needsMyApproval;
            }
          } catch (_) {
            // Best-effort: skip matches whose join requests couldn't be fetched.
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _feedMatches = feedMatches;
        _notifications = notifications;
        _pendingApprovalsByMatchId = pendingApprovals;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudieron cargar los datos.\nVerifica que el backend esté disponible.';
      });
    }
  }

  void _showJoinRequestWorkflow(Match match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Solicitar Unirse',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Deseas enviar una solicitud para unirte al partido de ${match.title} organizado por ${match.createdBy.name}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _createJoinRequestAndShowDialog(match);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Enviar Solicitud', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _createJoinRequestAndShowDialog(Match match) async {
    try {
      final request = await _createJoinRequestUseCase.execute(match.id);
      if (!mounted) return;
      _runConsensusWorkflowDialog(match, request);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar la solicitud: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _runConsensusWorkflowDialog(Match match, MatchJoinRequest initialRequest) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _ConsensusDialogContent(
          matchId: match.id,
          creatorName: match.createdBy.name,
          initialRequest: initialRequest,
          getJoinRequestUseCase: _getJoinRequestUseCase,
          onApproved: _loadData,
        );
      },
    );
  }

  Future<void> _approveJoinRequest(String matchId, MatchJoinRequest request) async {
    try {
      await _approveJoinRequestUseCase.execute(matchId, request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aprobaste la solicitud de ${request.requesterName}.'),
          backgroundColor: AppColors.primary,
        ),
      );
      _loadData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo aprobar la solicitud: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 0),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _ErrorView(message: _errorMessage!, onRetry: _loadData)
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FEED DE ACTIVIDADES',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Inicio',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_notifications.isNotEmpty) ...[
                            const Text(
                              'Notificaciones recientes',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: _notifications.take(5).map((notif) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            notif.message,
                                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (_pendingApprovalsByMatchId.isNotEmpty) ...[
                            const Text(
                              'Solicitudes que esperan tu aprobación',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            for (final entry in _pendingApprovalsByMatchId.entries) ...[
                              for (final request in entry.value) ...[
                                _PendingApprovalCard(
                                  request: request,
                                  onApprove: () => _approveJoinRequest(entry.key, request),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                            const SizedBox(height: 14),
                          ],

                          const Text(
                            'Partidos de mis amigos',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (_feedMatches.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'No hay partidos disponibles por el momento.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          for (final match in _feedMatches) ...[
                            _FriendMatchCard(
                              match: match,
                              onJoin: () => _showJoinRequestWorkflow(match),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _PendingApprovalCard extends StatelessWidget {
  final MatchJoinRequest request;
  final VoidCallback onApprove;

  const _PendingApprovalCard({required this.request, required this.onApprove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.how_to_reg, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${request.requesterName} quiere unirse a tu partido (${request.approvalsCount}/${request.requiredApprovals} aprobaciones)',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Aprobar', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _FriendMatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onJoin;

  const _FriendMatchCard({
    required this.match,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final spotsLeft = match.maxPlayers - match.currentPlayers;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.courtName.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$spotsLeft LUGARES',
                  style: const TextStyle(
                    color: Color(0xFF9A6B00),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Partido de ${match.createdBy.name}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  match.courtName,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${match.dateTime.day}/${match.dateTime.month} a las ${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Participantes: ${match.participants.map((p) => p.name).join(', ')}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Solicitar unirse',
                style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsensusDialogContent extends StatefulWidget {
  final String matchId;
  final String creatorName;
  final MatchJoinRequest initialRequest;
  final GetMatchJoinRequestUseCase getJoinRequestUseCase;
  final VoidCallback onApproved;

  const _ConsensusDialogContent({
    required this.matchId,
    required this.creatorName,
    required this.initialRequest,
    required this.getJoinRequestUseCase,
    required this.onApproved,
  });

  @override
  State<_ConsensusDialogContent> createState() => _ConsensusDialogContentState();
}

class _ConsensusDialogContentState extends State<_ConsensusDialogContent> {
  late MatchJoinRequest _request;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _request = widget.initialRequest;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final updated = await widget.getJoinRequestUseCase.execute(widget.matchId, _request.id);
      if (!mounted) return;
      setState(() {
        _request = updated;
      });
      if (updated.isApproved) {
        _pollTimer?.cancel();
        widget.onApproved();
      }
    } catch (_) {
      // Transient network errors: keep polling, don't surface a dialog error.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _request.isApproved;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: const [
          Icon(Icons.diversity_3, color: AppColors.primary),
          SizedBox(width: 10),
          Text('Aprobación por Consenso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isApproved
                ? '¡Todos los participantes aprobaron tu solicitud!'
                : 'Todos los participantes del partido deben aprobar tu solicitud. Puedes cerrar esta ventana: te avisaremos con una notificación.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (isApproved)
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
              else
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_request.approvalsCount}/${_request.requiredApprovals} participantes han aprobado',
                  style: TextStyle(
                    color: isApproved ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isApproved ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: isApproved
              ? ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Entendido', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
                )
              : TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
                ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar', style: TextStyle(color: AppColors.darkNavy)),
            ),
          ],
        ),
      ),
    );
  }
}
