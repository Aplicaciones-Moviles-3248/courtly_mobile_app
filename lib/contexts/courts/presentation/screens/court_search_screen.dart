import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_courts_use_case.dart';
import '../../domain/entities/court.dart';
import '../../infrastructure/datasources/court_remote_data_source.dart';
import '../../infrastructure/repositories/court_repository_impl.dart';

class CourtSearchScreen extends StatefulWidget {
  const CourtSearchScreen({super.key});

  @override
  State<CourtSearchScreen> createState() => _CourtSearchScreenState();
}

class _CourtSearchScreenState extends State<CourtSearchScreen> {
  late final GetCourtsUseCase getCourtsUseCase;

  List<Court> allCourts = [];
  List<Court> filteredCourts = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedLocation = 'Todas';
  String selectedSport = 'Todos';
  String selectedPrice = 'Todos';
  String selectedSchedule = 'Todos';

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);
    final dataSource = CourtRemoteDataSource(apiClient);
    final repository = CourtRepositoryImpl(dataSource);

    getCourtsUseCase = GetCourtsUseCase(repository);

    loadCourts();
  }

  Future<void> loadCourts() async {
    try {
      final courts = await getCourtsUseCase.execute();

      setState(() {
        allCourts = courts;
        filteredCourts = courts;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se pudieron cargar las canchas.\nVerifica que el backend esté disponible.';
      });
    }
  }

  List<String> get locationOptions {
    final locations = allCourts
        .map((court) => court.district)
        .where((location) => location.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['Todas', ...locations];
  }

  List<String> get sportOptions {
    final sports = allCourts
        .map((court) => court.sport)
        .where((sport) => sport.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['Todos', ...sports];
  }

  void applyFilters() {
    final result = allCourts.where((court) {
      final matchesLocation = selectedLocation == 'Todas' ||
          court.district.toLowerCase() == selectedLocation.toLowerCase();

      final matchesSport = selectedSport == 'Todos' ||
          court.sport.toLowerCase() == selectedSport.toLowerCase();

      final matchesPrice = _matchesPrice(court.pricePerHour);

      final matchesSchedule = _matchesSchedule(court.availableSchedules);

      return matchesLocation && matchesSport && matchesPrice && matchesSchedule;
    }).toList();

    setState(() {
      filteredCourts = result;
    });
  }

  bool _matchesPrice(double price) {
    switch (selectedPrice) {
      case 'Hasta S/ 80':
        return price <= 80;
      case 'Hasta S/ 100':
        return price <= 100;
      case 'Hasta S/ 120':
        return price <= 120;
      case 'Más de S/ 120':
        return price > 120;
      default:
        return true;
    }
  }

  bool _matchesSchedule(int availableSchedules) {
    switch (selectedSchedule) {
      case 'Con horarios':
        return availableSchedules > 0;
      case 'Sin horarios':
        return availableSchedules == 0;
      default:
        return true;
    }
  }

  void clearFilters() {
    setState(() {
      selectedLocation = 'Todas';
      selectedSport = 'Todos';
      selectedPrice = 'Todos';
      selectedSchedule = 'Todos';
      filteredCourts = allCourts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 1),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'BÚSQUEDA DE CANCHAS',
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
                  _FilterCard(
                    selectedLocation: selectedLocation,
                    selectedSport: selectedSport,
                    selectedPrice: selectedPrice,
                    selectedSchedule: selectedSchedule,
                    locationOptions: locationOptions,
                    sportOptions: sportOptions,
                    onLocationChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                      });
                    },
                    onSportChanged: (value) {
                      setState(() {
                        selectedSport = value;
                      });
                    },
                    onPriceChanged: (value) {
                      setState(() {
                        selectedPrice = value;
                      });
                    },
                    onScheduleChanged: (value) {
                      setState(() {
                        selectedSchedule = value;
                      });
                    },
                    onApplyFilters: applyFilters,
                    onClearFilters: clearFilters,
                  ),
                  const SizedBox(height: 16),
                  _ResultSummary(
                    total: filteredCourts.length,
                    hasFilters: selectedLocation != 'Todas' ||
                        selectedSport != 'Todos' ||
                        selectedPrice != 'Todos' ||
                        selectedSchedule != 'Todos',
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildCourtResults(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtResults() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (filteredCourts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'No se encontraron canchas con los filtros seleccionados.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 110),
      itemCount: filteredCourts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return _CourtCard(court: filteredCourts[index]);
      },
    );
  }
}

class _FilterCard extends StatelessWidget {
  final String selectedLocation;
  final String selectedSport;
  final String selectedPrice;
  final String selectedSchedule;
  final List<String> locationOptions;
  final List<String> sportOptions;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onSportChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onScheduleChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;

  const _FilterCard({
    required this.selectedLocation,
    required this.selectedSport,
    required this.selectedPrice,
    required this.selectedSchedule,
    required this.locationOptions,
    required this.sportOptions,
    required this.onLocationChanged,
    required this.onSportChanged,
    required this.onPriceChanged,
    required this.onScheduleChanged,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

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
          _FilterDropdown(
            label: 'UBICACIÓN',
            value: selectedLocation,
            options: locationOptions,
            onChanged: onLocationChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: 'DEPORTE',
                  value: selectedSport,
                  options: sportOptions,
                  onChanged: onSportChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterDropdown(
                  label: 'PRECIO MÁXIMO',
                  value: selectedPrice,
                  options: const [
                    'Todos',
                    'Hasta S/ 80',
                    'Hasta S/ 100',
                    'Hasta S/ 120',
                    'Más de S/ 120',
                  ],
                  onChanged: onPriceChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterDropdown(
            label: 'HORARIO',
            value: selectedSchedule,
            options: const [
              'Todos',
              'Con horarios',
              'Sin horarios',
            ],
            onChanged: onScheduleChanged,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onApplyFilters,
            child: const Text('Aplicar filtros'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onClearFilters,
            child: const Text('Limpiar filtros'),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value) ? value : options.first;

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
        DropdownButtonFormField<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF4F8FB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _ResultSummary extends StatelessWidget {
  final int total;
  final bool hasFilters;

  const _ResultSummary({
    required this.total,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasFilters) {
      return const SizedBox.shrink();
    }

    return Text(
      '$total resultado${total == 1 ? '' : 's'} encontrado${total == 1 ? '' : 's'}',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
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
    final hasSchedules = court.availableSchedules > 0;

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
            Stack(
              children: [
                Image.network(
                  court.imageUrl,
                  height: 96,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto de la cancha ${court.name}',
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 96,
                      width: double.infinity,
                      color: const Color(0xFFF4F8FB),
                      child: const Icon(
                        Icons.sports_tennis,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasSchedules
                          ? const Color(0xFFE7FFF5)
                          : const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasSchedules ? 'Disponible' : 'Pocos slots',
                      style: TextStyle(
                        color: hasSchedules
                            ? AppColors.primaryDark
                            : const Color(0xFF9A6B00),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
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
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${court.sport} · ${court.availableSchedules} horarios',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
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
            ),
          ],
        ),
      ),
    );
  }
}