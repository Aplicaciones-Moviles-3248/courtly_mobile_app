import 'package:flutter/material.dart';

import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_available_coaches_use_case.dart';
import '../../domain/entities/coach.dart';
import '../../infrastructure/datasources/coach_remote_data_source.dart';
import '../../infrastructure/repositories/coach_repository_impl.dart';
import '../../../../app/routes/app_routes.dart';

class AvailableCoachesScreen extends StatefulWidget {
  const AvailableCoachesScreen({super.key});

  @override
  State<AvailableCoachesScreen> createState() => _AvailableCoachesScreenState();
}

class _AvailableCoachesScreenState extends State<AvailableCoachesScreen> {
  late final GetAvailableCoachesUseCase _getAvailableCoachesUseCase;
  late Future<List<Coach>> _coachesFuture;

  String _query = '';

  static const Color darkNavy = Color(0xFF061529);
  static const Color mutedText = Color(0xFF52657A);
  static const Color lightText = Color(0xFF8EA0B7);

  @override
  void initState() {
    super.initState();

    final localStorageService = LocalStorageService();
    final apiClient = ApiClient(localStorageService);
    final dataSource = CoachRemoteDataSource(apiClient);
    final repository = CoachRepositoryImpl(dataSource);

    _getAvailableCoachesUseCase = GetAvailableCoachesUseCase(repository);
    _coachesFuture = _getAvailableCoachesUseCase.execute();
  }

  List<Coach> _filterCoaches(List<Coach> coaches) {
    final normalizedQuery = _query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return coaches;
    }

    return coaches.where((coach) {
      return coach.name.toLowerCase().contains(normalizedQuery) ||
          coach.expertise.toLowerCase().contains(normalizedQuery) ||
          coach.phone.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Future<void> _refreshCoaches() async {
    setState(() {
      _coachesFuture = _getAvailableCoachesUseCase.execute();
    });

    await _coachesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCoaches,
          child: FutureBuilder<List<Coach>>(
            future: _coachesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return _ErrorView(
                  error: snapshot.error.toString(),
                  onRetry: _refreshCoaches,
                );
              }

              final coaches = snapshot.data ?? [];
              final filteredCoaches = _filterCoaches(coaches);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BÚSQUEDA DE ENTRENADORES',
                            style: TextStyle(
                              color: lightText,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.7,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Coaches y\ndisponibilidades',
                            style: TextStyle(
                              color: darkNavy,
                              fontSize: 25,
                              height: 1.02,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Explora perfiles, revisa disponibilidad y luego crea la training session.',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _query = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar coach o especialidad',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF4F8FB),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  if (filteredCoaches.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyAvailableCoaches(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(26, 0, 26, 28),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return _CoachCard(
                              coach: filteredCoaches[index],
                              index: index,
                            );
                          },
                          childCount: filteredCoaches.length,
                        ),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.48,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final int index;

  const _CoachCard({
    required this.coach,
    required this.index,
  });

  static const Color darkNavy = Color(0xFF061529);
  static const Color softGreen = Color(0xFFE4FAF2);
  static const Color mutedText = Color(0xFF52657A);

  String get rating {
    final ratings = ['4.9/5', '4.8/5', '4.7/5', '4.6/5'];
    return ratings[index % ratings.length];
  }

  String get imageUrl {
    final images = [
      'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=500',
    ];

    return images[index % images.length];
  }

  String get description {
    final expertise = coach.expertise.trim();

    if (expertise.isEmpty) {
      return 'Sesiones personalizadas para mejorar técnica, rendimiento y preparación deportiva.';
    }

    return 'Entrenamiento enfocado en técnica, preparación y sesiones individuales.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18061529),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE7EDF3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 128,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE9F0F6),
                      child: Center(
                        child: Text(
                          coach.name.isNotEmpty
                              ? coach.name[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: darkNavy,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    rating,
                    style: const TextStyle(
                      color: darkNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkNavy,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.expertise,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkNavy,
                      fontSize: 12,
                      height: 1.28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${coach.availableSlots} slots disponibles',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF009E73),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.coachDetail,
                                arguments: coach,
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: softGreen,
                              foregroundColor: darkNavy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Ver\nperfil',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.coachSessionRequest,
                                arguments: coach,
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: darkNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Reservar\nslot',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _ErrorView extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.error_outline,
          size: 56,
          color: Color(0xFF061529),
        ),
        const SizedBox(height: 16),
        const Text(
          'No se pudieron cargar los entrenadores disponibles.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF061529),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF52657A),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onRetry,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}

class _EmptyAvailableCoaches extends StatelessWidget {
  const _EmptyAvailableCoaches();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 58,
            color: Color(0xFF061529),
          ),
          SizedBox(height: 16),
          Text(
            'No se encontraron entrenadores disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF061529),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta buscar con otro nombre o especialidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF52657A),
            ),
          ),
        ],
      ),
    );
  }
}