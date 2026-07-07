import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_exception.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../../bookings/application/use_cases/cancel_booking_use_case.dart';
import '../../../bookings/application/use_cases/get_my_bookings_use_case.dart';
import '../../../bookings/domain/entities/booking.dart';
import '../../../bookings/domain/value_objects/booking_status.dart';
import '../../../bookings/infrastructure/datasources/booking_remote_data_source.dart';
import '../../../bookings/infrastructure/repositories/booking_repository_impl.dart';
import '../../../reviews/application/use_cases/create_review_use_case.dart';
import '../../../reviews/application/use_cases/get_reviews_use_case.dart';
import '../../../reviews/domain/entities/review.dart';
import '../../../reviews/infrastructure/datasources/review_remote_data_source.dart';
import '../../../reviews/infrastructure/models/review_model.dart';
import '../../../reviews/infrastructure/repositories/review_repository_impl.dart';
import '../../../reviews/presentation/widgets/review_card.dart';
import '../../../reviews/presentation/widgets/review_form_bottom_sheet.dart';
import '../../../users/application/use_cases/get_my_user_profile_use_case.dart';
import '../../../users/domain/entities/user_profile.dart';
import '../../../users/infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../../users/infrastructure/repositories/user_profile_repository_impl.dart';
import '../../application/use_cases/get_court_detail_use_case.dart';
import '../../domain/entities/court.dart';
import '../../infrastructure/datasources/court_remote_data_source.dart';
import '../../infrastructure/repositories/court_repository_impl.dart';

class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  late final GetCourtDetailUseCase getCourtDetailUseCase;
  late final GetMyBookingsUseCase getMyBookingsUseCase;
  late final CancelBookingUseCase cancelBookingUseCase;
  late final GetReviewsUseCase getReviewsUseCase;
  late final CreateReviewUseCase createReviewUseCase;
  late final GetMyUserProfileUseCase getMyUserProfileUseCase;
  late final LocalStorageService localStorage;

  late String courtId;

  Booking? activeBooking;
  Booking? demoCompletedBookingForReview;
  Booking? ownedCompletedBookingForReview;
  UserProfile? currentUserProfile;
  bool loadingBooking = true;
  bool loadingReviews = true;
  bool publishingReview = false;
  List<Review> reviews = [];
  String? bookingStateCourtId;
  String? reviewsCourtId;

  @override
  void initState() {
    super.initState();

    localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);

    final dataSource = CourtRemoteDataSource(apiClient);
    final repository = CourtRepositoryImpl(dataSource);

    final bookingDataSource = BookingRemoteDataSource(apiClient);
    final bookingRepository = BookingRepositoryImpl(bookingDataSource);

    final reviewDataSource = ReviewRemoteDataSource(apiClient);
    final reviewRepository = ReviewRepositoryImpl(reviewDataSource);

    final userProfileDataSource = UserProfileRemoteDataSource(apiClient);
    final userProfileRepository = UserProfileRepositoryImpl(
      userProfileDataSource,
    );

    getCourtDetailUseCase = GetCourtDetailUseCase(repository);
    getMyBookingsUseCase = GetMyBookingsUseCase(bookingRepository);
    cancelBookingUseCase = CancelBookingUseCase(bookingRepository);
    getReviewsUseCase = GetReviewsUseCase(reviewRepository);
    createReviewUseCase = CreateReviewUseCase(reviewRepository);
    getMyUserProfileUseCase = GetMyUserProfileUseCase(userProfileRepository);
  }

  Future<void> loadBookingStates(String courtId) async {
    try {
      final currentUserId = await localStorage.getUserId();
      final currentUsername = await localStorage.getUsername();
      final currentProfile = await _loadCurrentProfile();
      final bookings = await getMyBookingsUseCase.execute();

      Booking? active;
      Booking? demoCompleted;
      Booking? ownedCompleted;
      var canReview = false;

      debugPrint('[USM08] Checking review eligibility');
      debugPrint('[USM08] currentCourtId=$courtId');
      debugPrint('[USM08] authenticated IAM user id = $currentUserId');
      debugPrint('[USM08] authenticated username = $currentUsername');
      debugPrint('[USM08] current profile id = ${currentProfile?.id}');
      debugPrint('[USM08] current profile name = ${currentProfile?.name}');
      debugPrint('[USM08] current profile email = ${currentProfile?.email}');
      debugPrint(
        '[USM08] authenticatedUserId=$currentUserId username=$currentUsername',
      );
      debugPrint('[USM08] totalBookings=${bookings.length}');

      for (final b in bookings) {
        final matchesCourt = _sameId(b.courtId, courtId);
        final matchesCompleted = b.status == BookingStatus.completed;
        final matchesUser = _matchesCurrentUser(
          booking: b,
          currentProfile: currentProfile,
          currentUsername: currentUsername,
        );
        final matchesProfileOwner = _matchesCurrentProfileOwner(
          booking: b,
          currentProfile: currentProfile,
        );
        final matchesForSprintDemo = matchesCourt && matchesCompleted;

        debugPrint(
          '[USM08] booking id=${b.id} status=${b.status.name} '
          'userId=${b.userId} userName=${b.userName} '
          'booking user id = ${b.userId} booking user name = ${b.userName} '
          'courtId=${b.courtId} courtName=${b.courtName} '
          'matchesCourt=$matchesCourt matchesCompleted=$matchesCompleted '
          'matchesUser=$matchesUser '
          'matchesProfileOwner=$matchesProfileOwner '
          'matchesForSprintDemo=$matchesForSprintDemo',
        );

        if (!matchesCourt) {
          continue;
        }

        if (active == null &&
            (b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.pendingPayment)) {
          active = b;
        }

        if (demoCompleted == null && matchesForSprintDemo) {
          demoCompleted = b;
          canReview = true;
        }

        if (ownedCompleted == null &&
            matchesForSprintDemo &&
            matchesProfileOwner) {
          ownedCompleted = b;
        }

        if (active != null && demoCompleted != null && ownedCompleted != null) {
          break;
        }
      }

      debugPrint(
        '[USM08] demo completed booking id = ${demoCompleted?.id ?? 'none'}',
      );
      debugPrint(
        '[USM08] owned completed booking id for review = ${ownedCompleted?.id ?? 'none'}',
      );
      debugPrint('[USM08] final canReview=$canReview');

      if (mounted) {
        setState(() {
          activeBooking = active;
          demoCompletedBookingForReview = demoCompleted;
          ownedCompletedBookingForReview = ownedCompleted;
          currentUserProfile = currentProfile;
          loadingBooking = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading booking status for reviews: $e');

      if (mounted) {
        setState(() {
          loadingBooking = false;
        });
      }
    }
  }

  Future<UserProfile?> _loadCurrentProfile() async {
    try {
      return await getMyUserProfileUseCase.execute();
    } catch (e) {
      debugPrint('[USM08] Could not load current user profile: $e');
      return null;
    }
  }

  bool _matchesCurrentUser({
    required Booking booking,
    required UserProfile? currentProfile,
    required String? currentUsername,
  }) {
    if (_matchesCurrentProfileOwner(
      booking: booking,
      currentProfile: currentProfile,
    )) {
      return true;
    }

    final hasReliableUsername =
        currentUsername != null && currentUsername.trim().isNotEmpty;

    final matchesUsername =
        hasReliableUsername &&
        (_sameUsername(booking.userName, currentUsername) ||
            currentUsername.trim().toLowerCase().startsWith(
              '${booking.userName.trim().toLowerCase()}@',
            ));

    return matchesUsername;
  }

  bool _matchesCurrentProfileOwner({
    required Booking booking,
    required UserProfile? currentProfile,
  }) {
    if (currentProfile == null) return false;

    final matchesProfileId = _sameId(
      booking.userId,
      currentProfile.id.toString(),
    );
    final matchesProfileName = _sameUsername(
      booking.userName,
      currentProfile.name,
    );
    final matchesProfileEmailPrefix = currentProfile.email
        .trim()
        .toLowerCase()
        .startsWith('${booking.userName.trim().toLowerCase()}@');

    return matchesProfileId || matchesProfileName || matchesProfileEmailPrefix;
  }

  bool _sameId(String left, String right) => left.trim() == right.trim();

  bool _sameUsername(String left, String right) =>
      left.trim().toLowerCase() == right.trim().toLowerCase();

  Future<void> loadReviews(String courtId) async {
    try {
      final allReviews = await getReviewsUseCase.execute();
      final courtReviews = allReviews.where((review) {
        final isCourtReview =
            review.targetType.toUpperCase() == 'COURT' ||
            review.type.toUpperCase() == 'COURT';

        return isCourtReview && review.targetId == courtId;
      }).toList();

      if (mounted) {
        setState(() {
          reviews = courtReviews;
          loadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading court reviews: $e');

      if (mounted) {
        setState(() {
          reviews = [];
          loadingReviews = false;
        });
      }
    }
  }

  Future<void> openReviewForm(Court court) async {
    if (demoCompletedBookingForReview == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes valorar canchas que ya utilizaste.'),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<ReviewFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReviewFormBottomSheet(courtName: court.name),
    );

    if (result == null) return;

    final bookingForPublishing = ownedCompletedBookingForReview;
    final profileForPublishing = currentUserProfile;
    final publishingAllowed =
        bookingForPublishing != null && profileForPublishing != null;

    debugPrint(
      '[USM08] owned completed booking id for review = ${bookingForPublishing?.id ?? 'none'}',
    );
    debugPrint(
      '[USM08] demo completed booking id = ${demoCompletedBookingForReview?.id ?? 'none'}',
    );
    debugPrint('[USM08] publishing allowed = $publishingAllowed');

    if (!publishingAllowed) {
      debugPrint(
        '[USM08] Cannot publish review: completed booking does not belong to authenticated user.',
      );
      // TODO: For final release, review publishing must use a completed booking
      // owned by the authenticated user.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se puede publicar la reseña porque la reserva completada pertenece a otro usuario.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => publishingReview = true);

    try {
      final token = await localStorage.getToken();
      final reviewPayload = ReviewModel.toCreateJson(
        score: result.score,
        comment: result.comment,
        courtId: court.id,
        userId: profileForPublishing.id.toString(),
        bookingId: bookingForPublishing.id,
      );

      debugPrint('[USM08] creating review');
      debugPrint('[USM08] token exists = ${token != null && token.isNotEmpty}');
      debugPrint(
        '[USM08] selected completed booking id for review = ${bookingForPublishing.id}',
      );
      debugPrint('[USM08] review payload = $reviewPayload');
      debugPrint('[USM08] final review payload = $reviewPayload');

      await createReviewUseCase.execute(
        score: result.score,
        comment: result.comment,
        courtId: court.id,
        userId: profileForPublishing.id.toString(),
        bookingId: bookingForPublishing.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña publicada correctamente.')),
      );

      await loadReviews(court.id);
    } catch (e) {
      debugPrint('Error creating court review: $e');
      if (e is ApiException && e.isUnauthorized) {
        debugPrint(
          '[USM08] Backend rejected review creation with 401. This may mean '
          'POST /reviews requires stricter ownership between authenticated '
          'user and booking.user.',
        );
        // TODO: Strict backend ownership requires logging in with the same IAM
        // user that owns the completed booking used to create the review.
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo publicar la reseña. Verifica que tengas una reserva completada.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => publishingReview = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    courtId = ModalRoute.of(context)?.settings.arguments as String? ?? '1';

    return Scaffold(
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 1),
      body: SafeArea(
        child: FutureBuilder<Court>(
          future: getCourtDetailUseCase.execute(courtId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final court = snapshot.data;

            if (court != null && bookingStateCourtId != court.id) {
              bookingStateCourtId = court.id;
              loadingBooking = true;
              loadBookingStates(court.id);
            }

            if (court != null && reviewsCourtId != court.id) {
              reviewsCourtId = court.id;
              loadingReviews = true;
              loadReviews(court.id);
            }

            if (court == null) {
              return const Center(child: Text('Court not found'));
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
                                value:
                                    'S/ ${court.pricePerHour.toStringAsFixed(0)}',
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
                          'Reseñas',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (loadingReviews)
                          const Center(child: CircularProgressIndicator())
                        else if (reviews.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Aún no hay reseñas para esta cancha.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: reviews
                                .map(
                                  (review) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ReviewCard(review: review),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                loadingBooking ||
                                    publishingReview ||
                                    demoCompletedBookingForReview == null
                                ? null
                                : () => openReviewForm(court),
                            child: publishingReview
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Valorar cancha'),
                          ),
                        ),
                        if (!loadingBooking &&
                            demoCompletedBookingForReview == null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Solo puedes valorar canchas que ya utilizaste.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (!loadingBooking &&
                            demoCompletedBookingForReview != null &&
                            ownedCompletedBookingForReview == null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Demo: existe una reserva completada para esta cancha, pero la publicación requiere que la reserva pertenezca al usuario autenticado.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (loadingBooking)
                          const Center(child: CircularProgressIndicator())
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
                              await cancelBookingUseCase.execute(
                                activeBooking!.id,
                              );

                              setState(() {
                                activeBooking = null;
                              });

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Reserva cancelada exitosamente.',
                                    ),
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

  const _InfoBox({required this.title, required this.value});

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
