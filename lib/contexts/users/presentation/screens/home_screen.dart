import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _matches = [
    {
      'id': 1,
      'creator': 'Fabricio',
      'participants': ['Fabricio'],
      'sport': 'Tenis',
      'court': 'Cancha Principal - San Isidro',
      'dateTime': 'Hoy, 18:00 - 19:00',
      'spots': 4,
      'joined': false,
    },
    {
      'id': 2,
      'creator': 'Eduardo',
      'participants': ['Eduardo', 'Camilla'],
      'sport': 'Fútbol',
      'court': 'Complejo Depor3 - Surco',
      'dateTime': 'Mañana, 20:00 - 21:00',
      'spots': 10,
      'joined': false,
    }
  ];

  List<String> _notifications = [
    'Tu reserva en San Borja ha sido confirmada.',
    'El entrenador Fabricio Ruiz aceptó tu solicitud de entrenamiento.',
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedIds = prefs.getStringList('joined_matches_ids') ?? [];
    setState(() {
      for (var match in _matches) {
        if (joinedIds.contains(match['id'].toString())) {
          match['joined'] = true;
          if (!match['participants'].contains('Tú')) {
            match['participants'].add('Tú');
          }
        }
      }
    });
  }

  Future<void> _saveJoinedState(int matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final joinedIds = prefs.getStringList('joined_matches_ids') ?? [];
    if (!joinedIds.contains(matchId.toString())) {
      joinedIds.add(matchId.toString());
      await prefs.setStringList('joined_matches_ids', joinedIds);
    }
  }

  void _showJoinRequestWorkflow(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Solicitar Unirse',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Deseas enviar una solicitud para unirte al partido de ${match['sport']} organizado por ${match['creator']}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _runConsensusWorkflowDialog(match);
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

  void _runConsensusWorkflowDialog(Map<String, dynamic> match) {
    final participants = List<String>.from(match['participants']);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _ConsensusDialogContent(
          participants: participants,
          creator: match['creator'],
          onComplete: () async {
            await _saveJoinedState(match['id']);
            setState(() {
              match['joined'] = true;
              if (!match['participants'].contains('Tú')) {
                match['participants'].add('Tú');
              }
              _notifications.insert(0, '¡Fuiste aceptado en el partido de ${match['sport']} de ${match['creator']}!');
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Notifications header card
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
                    children: _notifications.map((notif) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                notif,
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

              // Friends matches feed
              const Text(
                'Partidos de mis amigos',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (final match in _matches) ...[
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
    );
  }
}

class _FriendMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback onJoin;

  const _FriendMatchCard({
    required this.match,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final spotsLeft = match['spots'] - match['participants'].length;

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
                match['sport'].toUpperCase(),
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
                  color: match['joined'] ? const Color(0xFFE7FFF5) : const Color(0xFFFFF7E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match['joined'] ? 'UNIDO' : '$spotsLeft LUGARES',
                  style: TextStyle(
                    color: match['joined'] ? AppColors.primaryDark : const Color(0xFF9A6B00),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Partido de ${match['creator']}',
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
                  match['court'],
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
                match['dateTime'],
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Participantes: ${match['participants'].join(', ')}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          if (!match['joined'])
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
            )
          else
            const SizedBox(
              width: double.infinity,
              height: 44,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Ya formas parte de este partido',
                      style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsensusDialogContent extends StatefulWidget {
  final List<String> participants;
  final String creator;
  final VoidCallback onComplete;

  const _ConsensusDialogContent({
    required this.participants,
    required this.creator,
    required this.onComplete,
  });

  @override
  State<_ConsensusDialogContent> createState() => _ConsensusDialogContentState();
}

class _ConsensusDialogContentState extends State<_ConsensusDialogContent> {
  int _step = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startWorkflow();
  }

  void _startWorkflow() async {
    // Step 0: Request sent
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() { _step = 1; });

    // Step 1: Creator approves
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() { _step = 2; });

    // Step 2: Other participants approve if exists
    if (widget.participants.length > 1) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() { _step = 3; });
    } else {
      setState(() { _step = 3; });
    }

    // Step 3: Consensus complete & added
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _finished = true;
    });
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Todos los participantes del partido deben estar de acuerdo en incorporarte:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          _WorkflowStepRow(
            label: 'Enviando solicitud de unirse...',
            isActive: _step >= 0,
            isComplete: _step > 0,
          ),
          _WorkflowStepRow(
            label: 'Aprobación del creador (${widget.creator})',
            isActive: _step >= 1,
            isComplete: _step > 1,
          ),
          if (widget.participants.length > 1)
            _WorkflowStepRow(
              label: 'Consenso de participantes (${widget.participants.where((p) => p != widget.creator).join(", ")})',
              isActive: _step >= 2,
              isComplete: _step > 2,
            ),
          _WorkflowStepRow(
            label: 'Notificando incorporación con éxito',
            isActive: _step >= 3,
            isComplete: _finished,
          ),
        ],
      ),
      actions: [
        if (_finished)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Entendido', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class _WorkflowStepRow extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isComplete;

  const _WorkflowStepRow({
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          if (isComplete)
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
              label,
              style: TextStyle(
                color: isComplete ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
