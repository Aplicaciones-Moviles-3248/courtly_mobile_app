import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../domain/entities/coach.dart';

class CoachSessionRequestScreen extends StatefulWidget {
  const CoachSessionRequestScreen({super.key});

  @override
  State<CoachSessionRequestScreen> createState() =>
      _CoachSessionRequestScreenState();
}

class _CoachSessionRequestScreenState
    extends State<CoachSessionRequestScreen> {
  static const Color darkNavy = Color(0xFF061529);
  static const Color primary = Color(0xFF2EC4A6);
  static const Color mutedText = Color(0xFF52657A);
  static const Color lightText = Color(0xFF8EA0B7);

  String _court = 'Arena Norte · S/ 120';
  String _availability = '15 Mar · 8:00 AM';

  final TextEditingController _objectiveController = TextEditingController(
    text: 'Trabajo tecnico con correccion de saque y desplazamiento.',
  );

  @override
  void dispose() {
    _objectiveController.dispose();
    super.dispose();
  }

  void _createRequest() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Solicitud creada. El coach debe aceptarla o rechazarla antes del pago.',
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final coach = ModalRoute.of(context)?.settings.arguments as Coach?;

    final coachName = coach?.name ?? 'Carlos Vega';
    final expertise = coach?.expertise ?? 'Preparacion futbol 7';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 28),
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
            const SizedBox(height: 10),
            const Text(
              'TRAINING SESSION',
              style: TextStyle(
                color: lightText,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Solicitar sesion con\nentrenador',
              style: TextStyle(
                color: darkNavy,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.03,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La solicitud debe incluir coach, disponibilidad y cancha',
              style: TextStyle(
                color: mutedText,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: _whiteCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryBox(
                    coachName: coachName,
                    expertise: expertise,
                    court: _court.split(' · ').first,
                    availability: _availability,
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Cancha para la sesion'),
                  const SizedBox(height: 7),
                  _SelectBox(
                    value: _court,
                    items: const [
                      'Arena Norte · S/ 120',
                      'Green Point Club · S/ 95',
                      'Urban Court · S/ 110',
                      'Match Hub · S/ 75',
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _court = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Disponibilidad del coach'),
                  const SizedBox(height: 7),
                  _SelectBox(
                    value: _availability,
                    items: const [
                      '15 Mar · 8:00 AM',
                      '16 Mar · 6:00 PM',
                      '17 Mar · 5:00 PM',
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _availability = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Objetivo de la sesion'),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _objectiveController,
                    maxLines: 5,
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _createRequest,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: darkNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Crear solicitud',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4FAF2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFB9F0DF),
                      ),
                    ),
                    child: const Text(
                      'Solicitud creada. El coach debe aceptarla o rechazarla antes del pago.',
                      style: TextStyle(
                        color: Color(0xFF009E73),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
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

class _SummaryBox extends StatelessWidget {
  final String coachName;
  final String expertise;
  final String court;
  final String availability;

  const _SummaryBox({
    required this.coachName,
    required this.expertise,
    required this.court,
    required this.availability,
  });

  static const Color darkNavy = _CoachSessionRequestScreenState.darkNavy;
  static const Color mutedText = _CoachSessionRequestScreenState.mutedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFDDE6EF),
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Coach', value: coachName),
          _SummaryRow(label: 'Especialidad', value: expertise),
          _SummaryRow(label: 'Cancha', value: court),
          _SummaryRow(label: 'Disponibilidad', value: availability),
          const _SummaryRow(label: 'Precio estimado', value: 'S/ 165'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  static const Color darkNavy = _CoachSessionRequestScreenState.darkNavy;
  static const Color mutedText = _CoachSessionRequestScreenState.mutedText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkNavy,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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

  static const Color darkNavy = _CoachSessionRequestScreenState.darkNavy;

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
      decoration: InputDecoration(
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
      ),
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