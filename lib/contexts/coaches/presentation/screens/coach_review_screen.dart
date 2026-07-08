import 'package:flutter/material.dart';

import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../../reviews/application/use_cases/create_review_use_case.dart';
import '../../../reviews/application/use_cases/get_reviews_use_case.dart';
import '../../../reviews/domain/entities/review.dart';
import '../../../reviews/infrastructure/datasources/review_remote_data_source.dart';
import '../../../reviews/infrastructure/repositories/review_repository_impl.dart';

class CoachReviewScreen extends StatefulWidget {
  const CoachReviewScreen({super.key});

  @override
  State<CoachReviewScreen> createState() => _CoachReviewScreenState();
}

class _CoachReviewScreenState extends State<CoachReviewScreen> {
  static const Color darkNavy = Color(0xFF061529);
  static const Color primary = Color(0xFF2EC4A6);
  static const Color mutedText = Color(0xFF52657A);
  static const Color lightText = Color(0xFF8EA0B7);

  late final LocalStorageService _localStorageService;
  late final ApiClient _apiClient;
  late final GetReviewsUseCase _getReviewsUseCase;
  late final CreateReviewUseCase _createReviewUseCase;

  late Future<List<Review>> _reviewsFuture;
  late Future<List<_ReviewableOperation>> _operationsFuture;

  String _selectedOperationKey = '';
  String _rating = '5';
  bool _isPublishing = false;

  final TextEditingController _commentController = TextEditingController(
    text: 'Excelente iluminación y buen mantenimiento.',
  );

  @override
  void initState() {
    super.initState();

    _localStorageService = LocalStorageService();
    _apiClient = ApiClient(_localStorageService);

    final dataSource = ReviewRemoteDataSource(_apiClient);
    final repository = ReviewRepositoryImpl(dataSource);

    _getReviewsUseCase = GetReviewsUseCase(repository);
    _createReviewUseCase = CreateReviewUseCase(repository);

    _reviewsFuture = _getReviewsUseCase.execute();
    _operationsFuture = _getReviewableOperations();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture = _getReviewsUseCase.execute();
      _operationsFuture = _getReviewableOperations();
    });

    await Future.wait([
      _reviewsFuture,
      _operationsFuture,
    ]);
  }

  Future<List<_ReviewableOperation>> _getReviewableOperations() async {
    final bookingsJson = await _apiClient.getList('/bookings');
    final trainingSessionsJson = await _apiClient.getList('/training-sessions');

    final operations = <_ReviewableOperation>[];

    for (final item in bookingsJson) {
      final booking = item as Map<String, dynamic>;
      final status = booking['status']?.toString().toUpperCase() ?? '';

      if (!_isCompletedStatus(status)) {
        continue;
      }

      final court = booking['court'];
      final courtMap = court is Map<String, dynamic> ? court : null;

      final bookingId = booking['id']?.toString();
      final courtId = courtMap?['id']?.toString();
      final courtName = courtMap?['name']?.toString() ?? 'Cancha';

      if (bookingId == null || courtId == null) {
        continue;
      }

      operations.add(
        _ReviewableOperation(
          key: 'booking-$bookingId',
          label: '$courtName - Reserva de cancha completada',
          targetId: courtId,
          targetType: 'COURT',
          bookingId: bookingId,
          trainingSessionId: null,
        ),
      );
    }

    for (final item in trainingSessionsJson) {
      final session = item as Map<String, dynamic>;
      final status = session['status']?.toString().toUpperCase() ?? '';

      if (!_isCompletedStatus(status)) {
        continue;
      }

      final coach = session['coach'];
      final coachMap = coach is Map<String, dynamic> ? coach : null;

      final trainingSessionId = session['id']?.toString();
      final coachId = coachMap?['id']?.toString();
      final coachName = coachMap?['name']?.toString() ?? 'Coach';

      if (trainingSessionId == null || coachId == null) {
        continue;
      }

      operations.add(
        _ReviewableOperation(
          key: 'training-session-$trainingSessionId',
          label: '$coachName - Sesión con coach completada',
          targetId: coachId,
          targetType: 'COACH',
          bookingId: null,
          trainingSessionId: trainingSessionId,
        ),
      );
    }

    return operations;
  }

  bool _isCompletedStatus(String status) {
    return status == 'COMPLETED' ||
        status == 'COMPLETE' ||
        status == 'FINISHED' ||
        status == 'DONE';
  }

  Future<void> _publishReview(List<_ReviewableOperation> operations) async {
    final comment = _commentController.text.trim();

    if (operations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes servicios completados disponibles para reseñar.',
          ),
        ),
      );
      return;
    }

    if (_selectedOperationKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un servicio completado.'),
        ),
      );
      return;
    }

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario para publicar la reseña.'),
        ),
      );
      return;
    }

    final selectedOperation = operations.firstWhere(
          (operation) => operation.key == _selectedOperationKey,
    );

    setState(() {
      _isPublishing = true;
    });

    try {
      final userId = await _localStorageService.getUserId();

      if (userId == null || userId == 0) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para publicar una reseña.'),
          ),
        );

        return;
      }

      await _createReviewUseCase.execute(
        score: int.parse(_rating),
        comment: comment,
        targetType: selectedOperation.targetType,
        targetId: selectedOperation.targetId,
        userId: userId.toString(),
        bookingId: selectedOperation.bookingId,
        trainingSessionId: selectedOperation.trainingSessionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reseña publicada correctamente.'),
        ),
      );

      _commentController.clear();

      setState(() {
        _selectedOperationKey = '';
        _rating = '5';
        _reviewsFuture = _getReviewsUseCase.execute();
        _operationsFuture = _getReviewableOperations();
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo publicar la reseña. Verifica que el servicio completado pertenezca a tu cuenta.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshReviews,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  '← Regresar',
                  style: TextStyle(
                    color: Color(0xFF009E73),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'RESEÑAS VÁLIDAS',
                style: TextStyle(
                  color: lightText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Valorar servicios\ncompletados',
                style: TextStyle(
                  color: darkNavy,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<_ReviewableOperation>>(
                future: _operationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ReviewFormLoadingCard();
                  }

                  if (snapshot.hasError) {
                    return _ReviewFormErrorCard(
                      error: snapshot.error.toString(),
                      onRetry: () {
                        setState(() {
                          _operationsFuture = _getReviewableOperations();
                        });
                      },
                    );
                  }

                  final operations = snapshot.data ?? [];

                  return _ReviewFormCard(
                    operations: operations,
                    selectedOperationKey: _selectedOperationKey,
                    rating: _rating,
                    isPublishing: _isPublishing,
                    commentController: _commentController,
                    onOperationChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedOperationKey = value;
                      });
                    },
                    onRatingChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _rating = value;
                      });
                    },
                    onPublish: () => _publishReview(operations),
                  );
                },
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ReviewsLoadingCard();
                  }

                  if (snapshot.hasError) {
                    return _ReviewsErrorCard(
                      error: snapshot.error.toString(),
                      onRetry: _refreshReviews,
                    );
                  }

                  final reviews = snapshot.data ?? [];

                  return _PublishedReviewsCard(
                    reviews: reviews,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewFormCard extends StatelessWidget {
  final List<_ReviewableOperation> operations;
  final String selectedOperationKey;
  final String rating;
  final bool isPublishing;
  final TextEditingController commentController;
  final ValueChanged<String?> onOperationChanged;
  final ValueChanged<String?> onRatingChanged;
  final VoidCallback onPublish;

  const _ReviewFormCard({
    required this.operations,
    required this.selectedOperationKey,
    required this.rating,
    required this.isPublishing,
    required this.commentController,
    required this.onOperationChanged,
    required this.onRatingChanged,
    required this.onPublish,
  });

  static const Color darkNavy = _CoachReviewScreenState.darkNavy;
  static const Color primary = _CoachReviewScreenState.primary;

  @override
  Widget build(BuildContext context) {
    final hasOperations = operations.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Servicio completado'),
          const SizedBox(height: 7),
          if (hasOperations)
            _OperationSelectBox(
              value: selectedOperationKey.isEmpty ? null : selectedOperationKey,
              operations: operations,
              onChanged: onOperationChanged,
            )
          else
            const _NoOperationsBox(),
          const SizedBox(height: 14),
          const _FieldLabel('Calificación'),
          const SizedBox(height: 7),
          _SelectBox(
            value: rating,
            items: const ['5', '4', '3', '2', '1'],
            onChanged: onRatingChanged,
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Comentario'),
          const SizedBox(height: 7),
          TextField(
            controller: commentController,
            maxLines: 5,
            enabled: hasOperations,
            style: const TextStyle(
              color: darkNavy,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF4F8FB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE6EF),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE6EF),
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE6EF),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: isPublishing ? null : onPublish,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: darkNavy,
                disabledBackgroundColor: const Color(0xFFB9EADD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isPublishing
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                'Publicar reseña',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationSelectBox extends StatelessWidget {
  final String? value;
  final List<_ReviewableOperation> operations;
  final ValueChanged<String?> onChanged;

  const _OperationSelectBox({
    required this.value,
    required this.operations,
    required this.onChanged,
  });

  static const Color darkNavy = _CoachReviewScreenState.darkNavy;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: const Text('Selecciona un servicio completado'),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: darkNavy,
      ),
      style: const TextStyle(
        color: darkNavy,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: _selectDecoration(),
      items: operations.map((operation) {
        return DropdownMenuItem<String>(
          value: operation.key,
          child: Text(
            operation.label,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _NoOperationsBox extends StatelessWidget {
  const _NoOperationsBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFDDE6EF),
        ),
      ),
      child: const Text(
        'No tienes servicios completados disponibles para reseñar.',
        style: TextStyle(
          color: Color(0xFF52657A),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectBox extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SelectBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const Color darkNavy = _CoachReviewScreenState.darkNavy;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: darkNavy,
      ),
      style: const TextStyle(
        color: darkNavy,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: _selectDecoration(),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

InputDecoration _selectDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF4F8FB),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Color(0xFFDDE6EF),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Color(0xFFDDE6EF),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Color(0xFF2EC4A6),
        width: 1.4,
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF52657A),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ReviewFormLoadingCard extends StatelessWidget {
  const _ReviewFormLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _whiteCardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ReviewFormErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ReviewFormErrorCard({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          const Text(
            'No se pudieron cargar los servicios completados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF061529),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF52657A),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _PublishedReviewsCard extends StatelessWidget {
  final List<Review> reviews;

  const _PublishedReviewsCard({
    required this.reviews,
  });

  static const Color darkNavy = _CoachReviewScreenState.darkNavy;

  @override
  Widget build(BuildContext context) {
    final visibleReviews = reviews.take(5).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reseñas publicadas desde\noperaciones reales',
            style: TextStyle(
              color: darkNavy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          if (visibleReviews.isEmpty)
            const Text(
              'Aún no hay reseñas publicadas.',
              style: TextStyle(
                color: Color(0xFF52657A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...visibleReviews.map(
                  (review) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _PublishedReviewItem(review: review),
              ),
            ),
        ],
      ),
    );
  }
}

class _PublishedReviewItem extends StatelessWidget {
  final Review review;

  const _PublishedReviewItem({
    required this.review,
  });

  static const Color darkNavy = _CoachReviewScreenState.darkNavy;
  static const Color mutedText = _CoachReviewScreenState.mutedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDDE6EF),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.targetType.isNotEmpty
                      ? review.targetType
                      : 'Reseña',
                  style: const TextStyle(
                    color: darkNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${review.userName}: ${review.comment}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE4FAF2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${review.score}/5',
              style: const TextStyle(
                color: Color(0xFF009E73),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsLoadingCard extends StatelessWidget {
  const _ReviewsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _whiteCardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ReviewsErrorCard extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _ReviewsErrorCard({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          const Text(
            'No se pudieron cargar las reseñas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF061529),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF52657A),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ReviewableOperation {
  final String key;
  final String label;
  final String targetId;
  final String targetType;
  final String? bookingId;
  final String? trainingSessionId;

  const _ReviewableOperation({
    required this.key,
    required this.label,
    required this.targetId,
    required this.targetType,
    required this.bookingId,
    required this.trainingSessionId,
  });
}

BoxDecoration _whiteCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFFE2EAF2),
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x12061529),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
    ],
  );
}