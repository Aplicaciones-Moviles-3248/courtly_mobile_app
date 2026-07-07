import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../../users/application/use_cases/get_my_user_profile_use_case.dart';
import '../../../users/domain/entities/user_profile.dart';
import '../../../users/infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../../users/infrastructure/repositories/user_profile_repository_impl.dart';
import '../../application/use_cases/get_all_matches_use_case.dart';
import '../../application/use_cases/join_match_use_case.dart';
import '../../domain/entities/match.dart';
import '../../infrastructure/datasources/match_remote_data_source.dart';
import '../../infrastructure/repositories/match_repository_impl.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late final GetAllMatchesUseCase getAllMatchesUseCase;
  late final JoinMatchUseCase joinMatchUseCase;
  late final GetMyUserProfileUseCase getMyUserProfileUseCase;
  late final TabController _tabController;

  List<Match> allMatches = [];
  UserProfile? currentUser;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    
    // Matches Use Cases
    final matchDataSource = MatchRemoteDataSource(apiClient);
    final matchRepository = MatchRepositoryImpl(matchDataSource);
    getAllMatchesUseCase = GetAllMatchesUseCase(matchRepository);
    joinMatchUseCase = JoinMatchUseCase(matchRepository);

    // User Use Cases
    final userDataSource = UserProfileRemoteDataSource(apiClient);
    final userRepository = UserProfileRepositoryImpl(userDataSource);
    getMyUserProfileUseCase = GetMyUserProfileUseCase(userRepository);

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = await getMyUserProfileUseCase.execute();
      final matches = await getAllMatchesUseCase.execute();

      setState(() {
        currentUser = user;
        allMatches = matches;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se pudieron cargar los datos.\nVerifica que el backend esté disponible.';
      });
    }
  }

  Future<void> _joinMatch(Match match) async {
    setState(() {
      isLoading = true;
    });
    try {
      await joinMatchUseCase.execute(match.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Te has unido al partido "${match.title}" correctamente.'),
          backgroundColor: AppColors.primary,
        ),
      );
      _loadData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al unirse: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List<Match> get availableMatches {
    if (currentUser == null) return [];
    return allMatches.where((m) {
      final isAlreadyJoined = m.participants.any((p) => p.id == currentUser!.id);
      return !isAlreadyJoined && (m.status == 'OPEN' || m.currentPlayers < m.maxPlayers);
    }).toList();
  }

  List<Match> get myMatches {
    if (currentUser == null) return [];
    return allMatches.where((m) {
      return m.participants.any((p) => p.id == currentUser!.id);
    }).toList();
  }

  void _showMatchDetails(Match match, bool isMyMatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isFull = match.currentPlayers >= match.maxPlayers;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isMyMatch 
                          ? AppColors.primary.withOpacity(0.15)
                          : (isFull ? Colors.redAccent.withOpacity(0.15) : AppColors.primary.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isMyMatch ? 'UNIDO' : (isFull ? 'LLENO' : 'DISPONIBLE'),
                      style: TextStyle(
                        color: isMyMatch ? AppColors.primary : (isFull ? Colors.redAccent : AppColors.primary),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.sports_soccer, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    match.courtName,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year} a las ${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Jugadores: ${match.currentPlayers} / ${match.maxPlayers}',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Descripción',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                match.description.isNotEmpty ? match.description : 'Sin descripción adicional.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Text(
                'Organizador',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      match.createdBy.name.isNotEmpty ? match.createdBy.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    match.createdBy.name,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (!isMyMatch && !isFull)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _joinMatch(match);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Unirme al partido',
                      style: TextStyle(
                        color: AppColors.darkNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (isMyMatch)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Ya formas parte de este partido',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/matches/create');
          if (created == true) {
            _loadData();
          }
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.darkNavy, size: 28),
      ),
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
                      _loadData();
                    },
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ENCUENTROS DEPORTIVOS',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Partidos',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 30,
                                height: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TabBar(
                              controller: _tabController,
                              indicatorColor: AppColors.primary,
                              labelColor: AppColors.textPrimary,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              tabs: const [
                                Tab(text: 'Buscar Partidos'),
                                Tab(text: 'Mis Partidos'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _MatchesList(
                              matches: availableMatches,
                              onMatchTap: (m) => _showMatchDetails(m, false),
                              emptyMessage: 'No hay partidos disponibles en este momento.',
                              onRefresh: _loadData,
                            ),
                            _MatchesList(
                              matches: myMatches,
                              onMatchTap: (m) => _showMatchDetails(m, true),
                              emptyMessage: 'No te has unido a ningún partido aún.',
                              onRefresh: _loadData,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _MatchesList extends StatelessWidget {
  final List<Match> matches;
  final Function(Match) onMatchTap;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const _MatchesList({
    required this.matches,
    required this.onMatchTap,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_soccer_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          final isFull = match.currentPlayers >= match.maxPlayers;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => onMatchTap(match),
              title: Text(
                match.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(match.courtName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${match.dateTime.day}/${match.dateTime.month} a las ${match.dateTime.hour.toString().padLeft(2, '0')}:${match.dateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${match.currentPlayers}/${match.maxPlayers}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isFull ? Colors.redAccent : AppColors.primary,
                    ),
                  ),
                  const Text('jugadores', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
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
