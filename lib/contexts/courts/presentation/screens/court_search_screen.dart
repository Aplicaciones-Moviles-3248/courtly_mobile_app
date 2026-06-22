import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_courts_use_case.dart';
import '../../domain/entities/court.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../infrastructure/datasources/court_remote_data_source.dart';
import '../../infrastructure/repositories/court_repository_impl.dart';

class CourtSearchScreen extends StatefulWidget {
  const CourtSearchScreen({super.key});

  @override
  State<CourtSearchScreen> createState() => _CourtSearchScreenState();
}

class _CourtSearchScreenState extends State<CourtSearchScreen> {
  late final GetCourtsUseCase getCourtsUseCase;
  late Future<List<Court>> courtsFuture;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    final dataSource = CourtRemoteDataSource(apiClient);
    final repository = CourtRepositoryImpl(dataSource);

    getCourtsUseCase = GetCourtsUseCase(repository);
    courtsFuture = getCourtsUseCase.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'BUSQUEDA DE CANCHAS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.payments),
                    icon: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Mis pagos',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Encuentra tu cancha',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Explora canchas con imagen, precio por hora y horarios disponibles',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              _FilterCard(),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Court>>(
                  future: courtsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'No se pudieron cargar las canchas.\nVerifica que el backend esté corriendo.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    final courts = snapshot.data ?? [];

                    if (courts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay canchas registradas.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: courts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        return _CourtCard(court: courts[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          _FilterField(label: 'UBICACION', value: 'Todas'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _FilterField(label: 'DEPORTE', value: 'Todos')),
              const SizedBox(width: 10),
              Expanded(child: _FilterField(label: 'PRECIO MAXIMO', value: 'Todos')),
            ],
          ),
          const SizedBox(height: 10),
          _FilterField(label: 'HORARIO', value: 'Todos'),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final String value;

  const _FilterField({
    required this.label,
    required this.value,
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FB),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourtCard extends StatelessWidget {
  final Court court;

  const _CourtCard({
    required this.court,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courtDetail,
          arguments: court.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              court.imageUrl,
              height: 96,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.district.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    court.name,
                    maxLines: 2,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${court.sport} · ${court.availableSchedules} horarios',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${court.pricePerHour.toStringAsFixed(0)} / hora',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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