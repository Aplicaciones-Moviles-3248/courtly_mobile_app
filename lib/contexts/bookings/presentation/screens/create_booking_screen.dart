import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../users/application/use_cases/get_my_user_profile_use_case.dart';
import '../../../users/infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../../users/infrastructure/repositories/user_profile_repository_impl.dart';
import '../../application/use_cases/create_booking_use_case.dart';
import '../../domain/entities/booking.dart';
import '../../infrastructure/datasources/booking_remote_data_source.dart';
import '../../infrastructure/repositories/booking_repository_impl.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late final CreateBookingUseCase createBookingUseCase;
  late final GetMyUserProfileUseCase getMyUserProfileUseCase;

  DateTime? _selectedDate;
  int? _selectedStartHour;
  int? _selectedEndHour;
  bool _isLoading = false;
  String? _errorMessage;

  List<String> _friends = [];
  final List<String> _selectedFriends = [];
  bool _splitPayment = false;

  @override
  void initState() {
    super.initState();

    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);

    final bookingDataSource = BookingRemoteDataSource(apiClient);
    final bookingRepository = BookingRepositoryImpl(bookingDataSource);
    createBookingUseCase = CreateBookingUseCase(bookingRepository);

    final userDataSource = UserProfileRemoteDataSource(apiClient);
    final userRepository = UserProfileRepositoryImpl(userDataSource);
    getMyUserProfileUseCase = GetMyUserProfileUseCase(userRepository);

    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('my_friends') ?? ['Fabricio', 'Eduardo', 'Camilla', 'Pedro'];
    setState(() {
      _friends = list;
    });
  }

  bool get _rangeValid =>
      _selectedStartHour != null &&
          _selectedEndHour != null &&
          _selectedEndHour! > _selectedStartHour!;

  bool get _canConfirm => _selectedDate != null && _rangeValid && !_isLoading;

  double _totalPrice(double pricePerHour) =>
      _rangeValid ? (_selectedEndHour! - _selectedStartHour!) * pricePerHour : 0;

  String _hourLabel(int h) => '${h.toString().padLeft(2, '0')}:00';

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';

  DateTime _buildDT(DateTime date, int hour) =>
      DateTime(date.year, date.month, date.day, hour);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.darkNavy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedStartHour = null;
        _selectedEndHour = null;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: isStart ? (_selectedStartHour ?? 8) : (_selectedEndHour ?? 9),
        minute: 0,
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.darkNavy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartHour = picked.hour;
          if (_selectedEndHour != null && _selectedEndHour! <= picked.hour) {
            _selectedEndHour = null;
          }
        } else {
          _selectedEndHour = picked.hour;
        }
      });
    }
  }

  Future<void> _confirm(String courtId, double pricePerHour) async {
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final profile = await getMyUserProfileUseCase.execute();
      final userId = profile.id.toString();

      final booking = await createBookingUseCase.execute(
        startTime: _buildDT(_selectedDate!, _selectedStartHour!),
        endTime: _buildDT(_selectedDate!, _selectedEndHour!),
        userId: userId,
        courtId: courtId,
      );

      if (!mounted) return;
      _showSuccess(booking);
    } catch (e) {
      setState(() =>
      _errorMessage = 'Error al crear la reserva. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Reserva creada',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Reserva #${booking.id}\nEstado: ${booking.status.label}',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>?;
    final courtId = (args?['courtId'] ?? '').toString();
    final courtName = args?['courtName'] as String? ?? 'Cancha';
    final pricePerHour = args?['pricePerHour'] ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reservar cancha',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sports_tennis_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(courtName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        Text('S/ ${pricePerHour.toStringAsFixed(0)} / hora',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const _Label('Fecha'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: _selectedDate != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18,
                        color: _selectedDate != null
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? _dateLabel(_selectedDate!)
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const _Label('Horario'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedStartHour != null
                              ? AppColors.primary
                              : AppColors.border,
                          width: _selectedStartHour != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 18,
                              color: _selectedStartHour != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            _selectedStartHour != null
                                ? _hourLabel(_selectedStartHour!)
                                : 'Desde',
                            style: TextStyle(
                              color: _selectedStartHour != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: _selectedStartHour != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(false),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedEndHour != null
                              ? AppColors.primary
                              : AppColors.border,
                          width: _selectedEndHour != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 18,
                              color: _selectedEndHour != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            _selectedEndHour != null
                                ? _hourLabel(_selectedEndHour!)
                                : 'Hasta',
                            style: TextStyle(
                              color: _selectedEndHour != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: _selectedEndHour != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_canConfirm) ...[
              const SizedBox(height: 24),
              const _Label('Invitar amigos a la reserva'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: _friends.map((friend) {
                    final isSelected = _selectedFriends.contains(friend);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(friend, style: const TextStyle(color: AppColors.textPrimary)),
                      activeColor: AppColors.primary,
                      checkColor: AppColors.darkNavy,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedFriends.add(friend);
                          } else {
                            _selectedFriends.remove(friend);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Label('Dividir pago equitativamente'),
                  Switch(
                    value: _splitPayment,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.38),
                    onChanged: (val) {
                      setState(() {
                        _splitPayment = val;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const _Label('Resumen'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                        label: 'Fecha',
                        value: _dateLabel(_selectedDate!)),
                    const SizedBox(height: 8),
                    _SummaryRow(
                        label: 'Horario',
                        value: '${_hourLabel(_selectedStartHour!)} – ${_hourLabel(_selectedEndHour!)}'),
                    const SizedBox(height: 8),
                    if (_selectedFriends.isNotEmpty) ...[
                      _SummaryRow(
                          label: 'Participantes',
                          value: '${_selectedFriends.length + 1} personas (tú + ${_selectedFriends.join(", ")})'),
                      const SizedBox(height: 8),
                    ],
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Total de la reserva',
                      value: 'S/ ${_totalPrice(pricePerHour).toStringAsFixed(0)}',
                      isTotal: !_splitPayment,
                    ),
                    if (_splitPayment) ...[
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Tú pagas (1/${_selectedFriends.length + 1})',
                        value: 'S/ ${(_totalPrice(pricePerHour) / (_selectedFriends.length + 1)).toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                      const SizedBox(height: 4),
                      _SummaryRow(
                        label: 'Cada amigo paga',
                        value: 'S/ ${(_totalPrice(pricePerHour) / (_selectedFriends.length + 1)).toStringAsFixed(2)}',
                        isTotal: false,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _canConfirm
                  ? () => _confirm(courtId, pricePerHour)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.darkNavy)),
              )
                  : const Text('Confirmar reserva',
                  style: TextStyle(
                      color: AppColors.darkNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w800),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isTotal
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                color: isTotal ? AppColors.primary : AppColors.textPrimary,
                fontSize: isTotal ? 15 : 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}