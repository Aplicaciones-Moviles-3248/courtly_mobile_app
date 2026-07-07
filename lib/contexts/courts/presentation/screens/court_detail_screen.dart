import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/get_court_detail_use_case.dart';
import '../../domain/entities/court.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../infrastructure/datasources/court_remote_data_source.dart';
import '../../infrastructure/repositories/court_repository_impl.dart';
import '../../../bookings/application/use_cases/get_my_bookings_use_case.dart';
import '../../../bookings/application/use_cases/cancel_booking_use_case.dart';
import '../../../bookings/domain/entities/booking.dart';
import '../../../bookings/domain/value_objects/booking_status.dart';
import '../../../bookings/infrastructure/datasources/booking_remote_data_source.dart';
import '../../../bookings/infrastructure/repositories/booking_repository_impl.dart';

class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  late final GetCourtDetailUseCase getCourtDetailUseCase;

  late final GetMyBookingsUseCase getMyBookingsUseCase;
  late final CancelBookingUseCase cancelBookingUseCase;

  late String courtId;

  Booking? activeBooking;
  bool loadingBooking = true;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);

    final dataSource = CourtRemoteDataSource(apiClient);
    final repository = CourtRepositoryImpl(dataSource);

    final bookingDataSource = BookingRemoteDataSource(apiClient);
    final bookingRepository = BookingRepositoryImpl(bookingDataSource);

    getCourtDetailUseCase = GetCourtDetailUseCase(repository);

    getMyBookingsUseCase = GetMyBookingsUseCase(bookingRepository);
    cancelBookingUseCase = CancelBookingUseCase(bookingRepository);
  }

  Future<void> loadBookingStatus(String courtId) async {
    try {
      final bookings = await getMyBookingsUseCase.execute();

      Booking? booking;

      for (final b in bookings) {
        if (b.courtId == courtId &&
            (b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.pendingPayment)) {
          booking = b;
          break;
        }
      }

      if (mounted) {
        setState(() {
          activeBooking = booking;
          loadingBooking = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          loadingBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    courtId = ModalRoute.of(context)?.settings.arguments as String? ?? '1';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 1),
      body: SafeArea(
        child: FutureBuilder<Court>(
          future: getCourtDetailUseCase.execute(courtId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final court = snapshot.data;

            if (court != null && loadingBooking) {
              loadBookingStatus(court.id);
            }

            if (court == null) {
              return const Center(
                child: Text('Court not found'),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    court.imageUrl,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${court.district.toUpperCase()} · ${court.sport.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          court.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          court.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoBox(
                                title: 'PRECIO POR HORA',
                                value: 'S/ ${court.pricePerHour.toStringAsFixed(0)}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoBox(
                                title: 'HORARIOS LIBRES',
                                value: '${court.availableSchedules}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Dirección',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          court.address,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Reseñas reales',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _ReviewCard(),
                        const SizedBox(height: 24),
                        if (loadingBooking)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (activeBooking == null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.createBooking,
                                arguments: {
                                  'courtId': court.id,
                                  'pricePerHour': court.pricePerHour,
                                },
                              );
                            },
                            child: const Text('Reservar esta cancha'),
                          )
                        else
                          OutlinedButton.icon(
                              onPressed: () async {
                                await cancelBookingUseCase.execute(activeBooking!.id);

                                setState(() {
                                  activeBooking = null;
                                });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reserva cancelada exitosamente.'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar reserva'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sofia Ramirez',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Jugador',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Calificación 5 de 5 estrellas',
            child: const Text(
              '★★★★★',
              style: TextStyle(
                color: Color(0xFFE0A800),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buen mantenimiento y acceso rapido.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}