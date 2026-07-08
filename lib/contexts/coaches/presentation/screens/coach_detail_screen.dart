import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/courtly_bottom_navigation_bar.dart';
import '../../domain/entities/coach.dart';
import '../../../../app/routes/app_routes.dart';

class CoachDetailScreen extends StatelessWidget {
  const CoachDetailScreen({super.key});

  static const Color darkNavy = Color(0xFF061529);
  static const Color cardNavy = Color(0xFF102A46);
  static const Color fieldNavy = Color(0xFF29435F);
  static const Color primary = Color(0xFF2EC4A6);
  static const Color softGreen = Color(0xFFE4FAF2);
  static const Color mutedText = Color(0xFF52657A);
  static const Color lightText = Color(0xFF8EA0B7);

  @override
  Widget build(BuildContext context) {
    final coach = ModalRoute.of(context)?.settings.arguments as Coach?;

    if (coach == null) {
      return Scaffold(
        bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
        body: SafeArea(
          child: Center(
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CourtlyBottomNavigationBar(currentIndex: 2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
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
            const SizedBox(height: 12),
            const Text(
              'PERFIL DEL COACH',
              style: TextStyle(
                color: lightText,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Detalle profesional',
              style: TextStyle(
                color: darkNavy,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 18),
            _CoachSummaryCard(coach: coach),
            const SizedBox(height: 14),
            _AvailabilityCard(coach: coach),
            const SizedBox(height: 14),
            const _ReviewsCard(),
            const SizedBox(height: 14),
            _ActionsCard(coach: coach),
          ],
        ),
      ),
    );
  }
}

class _CoachSummaryCard extends StatelessWidget {
  final Coach coach;

  const _CoachSummaryCard({
    required this.coach,
  });

  static const Color darkNavy = CoachDetailScreen.darkNavy;
  static const Color cardNavy = CoachDetailScreen.cardNavy;
  static const Color fieldNavy = CoachDetailScreen.fieldNavy;
  static const Color primary = CoachDetailScreen.primary;
  static const Color lightText = CoachDetailScreen.lightText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: cardNavy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22061529),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'COACH VERIFICADO',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: CoachDetailScreen.softGreen,
                child: Text(
                  coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: darkNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Text(
            coach.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _ProfileField(
            label: 'ESPECIALIDAD',
            value: coach.expertise,
          ),
          const SizedBox(height: 8),
          const _ProfileField(
            label: 'RATING',
            value: '4.9/5',
          ),
          const SizedBox(height: 8),
          _ProfileField(
            label: 'SESIONES COMPLETADAS',
            value: coach.availableSlots.toString(),
          ),
          const SizedBox(height: 8),
          const _ProfileField(
            label: 'BIO',
            value:
            'Entrenador enfocado en técnica, lectura de juego y sesiones individuales.',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _ProfileField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  static const Color fieldNavy = CoachDetailScreen.fieldNavy;
  static const Color lightText = CoachDetailScreen.lightText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      decoration: BoxDecoration(
        color: fieldNavy,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: lightText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final Coach coach;

  const _AvailabilityCard({
    required this.coach,
  });

  static const Color darkNavy = CoachDetailScreen.darkNavy;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _AvailabilityItem(
        date: '18 Mar',
        time: '8:00 PM',
        status: 'RESERVED',
        available: false,
      ),
      const _AvailabilityItem(
        date: '16 Mar',
        time: '6:00 PM',
        status: 'AVAILABLE',
        available: true,
      ),
      const _AvailabilityItem(
        date: '13 Mar',
        time: '8:00 PM',
        status: 'RESERVED',
        available: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disponibilidad publicada',
            style: TextStyle(
              color: darkNavy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          ...items,
        ],
      ),
    );
  }
}

class _AvailabilityItem extends StatelessWidget {
  final String date;
  final String time;
  final String status;
  final bool available;

  const _AvailabilityItem({
    required this.date,
    required this.time,
    required this.status,
    required this.available,
  });

  static const Color darkNavy = CoachDetailScreen.darkNavy;
  static const Color mutedText = CoachDetailScreen.mutedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
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
                  date,
                  style: const TextStyle(
                    color: darkNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
              available ? const Color(0xFFE4FAF2) : const Color(0xFFFFF3D8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: available
                    ? const Color(0xFF009E73)
                    : const Color(0xFFC17800),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard();

  static const Color darkNavy = CoachDetailScreen.darkNavy;
  static const Color primary = CoachDetailScreen.primary;
  static const Color mutedText = CoachDetailScreen.mutedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Reseñas válidas',
                  style: TextStyle(
                    color: darkNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.coachReview,
                  );
                },
                child: const Text(
                  'Escribir reseña',
                  style: TextStyle(
                    color: Color(0xFF009E73),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFDDE6EF),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sofía Ramírez',
                        style: TextStyle(
                          color: darkNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Correcciones claras y una sesión muy bien estructurada.',
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 11.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: CoachDetailScreen.softGreen,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '5/5',
                    style: TextStyle(
                      color: Color(0xFF009E73),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final Coach coach;

  const _ActionsCard({
    required this.coach,
  });

  static const Color darkNavy = CoachDetailScreen.darkNavy;
  static const Color softGreen = CoachDetailScreen.softGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.coachReview,
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: softGreen,
                  foregroundColor: darkNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Ver si puedo\nreseñar',
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
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 52,
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
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Reservar\ndisponibilidad',
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