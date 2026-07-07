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
  /// Repositorio inyectable. Si es null se construye el real contra el backend.
  /// Permite probar la pantalla sin acceso a la red.
  final PaymentRepository? repository;

  /// Resolutor del id de perfil inyectable para pruebas.
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
        errorMessage = 'No se pudieron cargar tus pagos. Verifica tu sesion o el backend.';
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

  Future<void> _openCreatePaymentSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePaymentSheet(
        resolveUserId: _resolveUserProfileId,
        createPaymentUseCase: createPaymentUseCase,
      ),
    );

    if (created == true) {
      await loadPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pagos')),
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 4),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePaymentSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkNavy,
        icon: const Icon(Icons.add),
        label: const Text('Registrar pago'),
      ),
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

    if (errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: 'Algo salio mal',
        message: errorMessage!,
        actionLabel: 'Reintentar',
        onAction: loadPayments,
      );
    }

    if (payments.isEmpty) {
      return _MessageState(
        icon: Icons.receipt_long_outlined,
        title: 'Aun no tienes pagos',
        message: 'Cuando registres un pago de una reserva o sesion, aparecera aqui.',
        actionLabel: 'Registrar pago',
        onAction: _openCreatePaymentSheet,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
      children: [
        const Text(
          'PAGOS REGISTRADOS',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Mis pagos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        for (final payment in payments) ...[
          _PaymentCard(payment: payment),
          const SizedBox(height: 14),
        ],
      ],
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
            label: payment.isTrainingSession ? 'Sesion' : 'Reserva',
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
    if (payment.isTrainingSession) return 'SESION DE ENTRENAMIENTO';
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
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

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 120, 28, 28),
      children: [
        Icon(icon, size: 56, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}

class _CreatePaymentSheet extends StatefulWidget {
  final Future<int?> Function() resolveUserId;
  final CreatePaymentUseCase createPaymentUseCase;

  const _CreatePaymentSheet({
    required this.resolveUserId,
    required this.createPaymentUseCase,
  });

  @override
  State<_CreatePaymentSheet> createState() => _CreatePaymentSheetState();
}

class _CreatePaymentSheetState extends State<_CreatePaymentSheet> {
  final formKey = GlobalKey<FormState>();
  final targetIdController = TextEditingController();

  bool isBooking = true;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void dispose() {
    targetIdController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      final userId = await widget.resolveUserId();
      if (userId == null) {
        throw Exception('No se pudo identificar tu perfil.');
      }

      final targetId = int.parse(targetIdController.text.trim());

      await widget.createPaymentUseCase.execute(
        userId: userId,
        bookingId: isBooking ? targetId : null,
        trainingSessionId: isBooking ? null : targetId,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      setState(() {
        isSubmitting = false;
        errorMessage = 'No se pudo registrar el pago. Revisa el identificador e intenta de nuevo.';
      });
    }
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
        child: Form(
          key: formKey,
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
                'Registrar pago',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'El monto se calcula en el backend segun la reserva o la sesion.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ContextOption(
                      label: 'Reserva',
                      isSelected: isBooking,
                      onTap: () => setState(() => isBooking = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ContextOption(
                      label: 'Sesion',
                      isSelected: !isBooking,
                      onTap: () => setState(() => isBooking = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: targetIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isBooking ? 'ID de la reserva' : 'ID de la sesion',
                  filled: true,
                  fillColor: const Color(0xFFF4F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Ingresa un identificador.';
                  if (int.tryParse(text) == null) {
                    return 'El identificador debe ser numerico.';
                  }
                  return null;
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar pago'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContextOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF4F8FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.darkNavy : AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
