import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../application/use_cases/create_payment_use_case.dart';
import '../../application/use_cases/get_my_payments_use_case.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../infrastructure/datasources/payment_remote_data_source.dart';
import '../../infrastructure/repositories/payment_repository_impl.dart';

class PaymentsScreen extends StatefulWidget {
  final PaymentRepository? repository;
  final Future<int?> Function()? resolveUserId;

  const PaymentsScreen({
    super.key,
    this.repository,
    this.resolveUserId,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  ApiClient? apiClient;
  late final GetMyPaymentsUseCase getMyPaymentsUseCase;
  late final CreatePaymentUseCase createPaymentUseCase;

  List<Payment> payments = const [];
  bool isLoading = true;
  String? errorMessage;

  bool demoPaymentCompleted = false;

  final List<_AcceptedTrainingSessionDemo> demoAcceptedSessions = const [
    _AcceptedTrainingSessionDemo(
      id: 1001,
      coachName: 'Eduardo Entrenador',
      sport: 'Entrenamiento personalizado',
      date: '08 Jul 2026',
      time: '08:00 AM',
      location: 'Cancha Courtly Demo',
      amount: 50.00,
      status: 'ACCEPTED',
    ),
  ];

  @override
  void initState() {
    super.initState();

    final PaymentRepository repository;
    if (widget.repository != null) {
      repository = widget.repository!;
    } else {
      final client = ApiClient(LocalStorageService());
      apiClient = client;
      repository = PaymentRepositoryImpl(PaymentRemoteDataSource(client));
    }

    getMyPaymentsUseCase = GetMyPaymentsUseCase(repository);
    createPaymentUseCase = CreatePaymentUseCase(repository);

    loadPayments();
  }

  Future<void> loadPayments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loaded = await getMyPaymentsUseCase.execute();
      setState(() {
        payments = loaded;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage =
        'No se pudieron cargar tus pagos. Verifica tu sesión o el backend.';
      });
    }
  }

  Future<int?> _resolveUserProfileId() async {
    if (widget.resolveUserId != null) {
      return widget.resolveUserId!();
    }

    final json = await apiClient!.get('/user-profiles/me');
    final id = json['id'];
    if (id is int) return id;
    return int.tryParse('${id ?? ''}');
  }

  Future<void> _openDemoPaymentSheet(
      _AcceptedTrainingSessionDemo session,
      ) async {
    final paid = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DemoPaymentSheet(session: session),
    );

    if (paid == true) {
      setState(() {
        demoPaymentCompleted = true;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago demo aprobado correctamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pagos'),
      ),
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPayments,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingDemoSessions =
    demoPaymentCompleted ? const <_AcceptedTrainingSessionDemo>[] : demoAcceptedSessions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
      children: [
        const Text(
          'PAGOS Y SESIONES',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gestiona tus pagos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Revisa tus sesiones aceptadas y registra el pago correspondiente.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        const _SectionTitle(
          title: 'Sesiones aceptadas por pagar',
          subtitle: 'Demo temporal para validar el flujo de pago.',
        ),
        const SizedBox(height: 12),

        if (pendingDemoSessions.isEmpty)
          const _InlineEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No tienes sesiones pendientes de pago',
            message:
            'Cuando un entrenador acepte una sesión, aparecerá aquí para realizar el pago.',
          )
        else
          for (final session in pendingDemoSessions) ...[
            _AcceptedTrainingSessionCard(
              session: session,
              onPay: () => _openDemoPaymentSheet(session),
            ),
            const SizedBox(height: 14),
          ],

        if (demoPaymentCompleted) ...[
          const SizedBox(height: 4),
          const _DemoCompletedPaymentCard(),
          const SizedBox(height: 18),
        ],

        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Historial de pagos',
          subtitle: 'Pagos registrados desde el backend.',
        ),
        const SizedBox(height: 12),

        if (errorMessage != null)
          _InlineErrorState(
            message: errorMessage!,
            onRetry: loadPayments,
          )
        else if (payments.isEmpty)
          const _InlineEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Aún no tienes pagos',
            message:
            'Cuando registres un pago de una reserva o sesión, aparecerá aquí.',
          )
        else
          for (final payment in payments) ...[
            _PaymentCard(payment: payment),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

class _AcceptedTrainingSessionDemo {
  final int id;
  final String coachName;
  final String sport;
  final String date;
  final String time;
  final String location;
  final double amount;
  final String status;

  const _AcceptedTrainingSessionDemo({
    required this.id,
    required this.coachName,
    required this.sport,
    required this.date,
    required this.time,
    required this.location,
    required this.amount,
    required this.status,
  });
}

class _AcceptedTrainingSessionCard extends StatelessWidget {
  final _AcceptedTrainingSessionDemo session;
  final VoidCallback onPay;

  const _AcceptedTrainingSessionCard({
    required this.session,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.sports_tennis,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.coachName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      session.sport,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const _AcceptedChip(),
            ],
          ),
          const SizedBox(height: 16),
          _PaymentRow(label: 'Sesión', value: '#${session.id}'),
          _PaymentRow(label: 'Fecha', value: '${session.date} · ${session.time}'),
          _PaymentRow(label: 'Lugar', value: session.location),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Monto a pagar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'S/ ${session.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.payment),
              label: const Text('Pagar ahora'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptedChip extends StatelessWidget {
  const _AcceptedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FFF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'ACEPTADA',
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DemoPaymentSheet extends StatefulWidget {
  final _AcceptedTrainingSessionDemo session;

  const _DemoPaymentSheet({
    required this.session,
  });

  @override
  State<_DemoPaymentSheet> createState() => _DemoPaymentSheetState();
}

class _DemoPaymentSheetState extends State<_DemoPaymentSheet> {
  bool isSubmitting = false;
  String selectedMethod = 'Tarjeta';

  Future<void> submitDemoPayment() async {
    setState(() {
      isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 850));

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Confirmar pago',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Valida el pago de la sesión aceptada por el entrenador.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _PaymentRow(label: 'Coach', value: widget.session.coachName),
                  _PaymentRow(label: 'Sesión', value: '#${widget.session.id}'),
                  _PaymentRow(
                    label: 'Horario',
                    value: '${widget.session.date} · ${widget.session.time}',
                  ),
                  _PaymentRow(
                    label: 'Total',
                    value: 'S/ ${widget.session.amount.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Método de pago',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PaymentMethodOption(
                    label: 'Tarjeta',
                    icon: Icons.credit_card,
                    isSelected: selectedMethod == 'Tarjeta',
                    onTap: () => setState(() => selectedMethod = 'Tarjeta'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentMethodOption(
                    label: 'Yape',
                    icon: Icons.phone_android,
                    isSelected: selectedMethod == 'Yape',
                    onTap: () => setState(() => selectedMethod = 'Yape'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitDemoPayment,
                child: isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Procesar pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF4F8FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? AppColors.darkNavy : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                isSelected ? AppColors.darkNavy : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoCompletedPaymentCard extends StatelessWidget {
  const _DemoCompletedPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FFF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB8F1DC)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primaryDark,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pago demo aprobado. La sesión fue marcada como pagada para validar el flujo visual.',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InlineEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 42,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudo cargar el historial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contextLabel(payment),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/ ${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: payment.status),
            ],
          ),
          const SizedBox(height: 14),
          _PaymentRow(label: 'Pago Nro', value: '#${payment.id}'),
          _PaymentRow(
            label: payment.isTrainingSession ? 'Sesión' : 'Reserva',
            value: payment.isTrainingSession
                ? '#${payment.trainingSessionId ?? '-'}'
                : '#${payment.bookingId ?? '-'}',
          ),
          _PaymentRow(label: 'Fecha', value: _formatDate(payment.paymentDate)),
        ],
      ),
    );
  }

  String _contextLabel(Payment payment) {
    if (payment.isTrainingSession) return 'SESIÓN DE ENTRENAMIENTO';
    if (payment.isBooking) return 'RESERVA DE CANCHA';
    return 'PAGO';
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: colors.$2,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'COMPLETADO';
      case 'PENDING':
        return 'PENDIENTE';
      case 'FAILED':
        return 'FALLIDO';
      case 'CANCELLED':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  (Color, Color) _statusColors(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return (const Color(0xFFE7FFF5), AppColors.primaryDark);
      case 'PENDING':
        return (const Color(0xFFFFF6E0), const Color(0xFF9A6B00));
      case 'FAILED':
      case 'CANCELLED':
        return (const Color(0xFFFFECEC), Colors.redAccent);
      default:
        return (AppColors.border, AppColors.textSecondary);
    }
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}