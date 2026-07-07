import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const TermsAndConditionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 430,
          maxHeight: mediaQuery.size.height * 0.82,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Términos y Condiciones',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TermsParagraph(
                      'Bienvenido a Courtly. Al acceder y utilizar nuestra '
                      'plataforma, aceptas los presentes Términos y '
                      'Condiciones. Te recomendamos leerlos atentamente antes '
                      'de usar nuestros servicios.',
                    ),
                    _TermsSection(
                      title: '1. Aceptación de los términos',
                      body:
                          'El uso de Courtly implica la aceptación plena de '
                          'estos términos. Si no estás de acuerdo con alguna '
                          'de sus disposiciones, te pedimos que no utilices la '
                          'plataforma.',
                    ),
                    _TermsSection(
                      title: '2. Descripción del servicio',
                      body:
                          'Courtly es una plataforma digital que permite a '
                          'los usuarios buscar y reservar canchas deportivas, '
                          'así como conectar con entrenadores independientes. '
                          'Algunas funciones pueden incluir gestión de '
                          'disponibilidad, pagos digitales, valoraciones y '
                          'notificaciones relacionadas con la actividad.',
                    ),
                    _TermsSection(
                      title: '3. Uso permitido',
                      body:
                          'El usuario se compromete a utilizar Courtly de '
                          'forma responsable, lícita y respetuosa. Está '
                          'prohibido usar la plataforma para fines '
                          'fraudulentos, para suplantar identidades, afectar '
                          'la experiencia de otros usuarios o vulnerar el '
                          'funcionamiento del sistema.',
                    ),
                    _TermsSection(
                      title: '4. Registro y cuenta',
                      body:
                          'Para acceder a ciertas funcionalidades, puede ser '
                          'necesario crear una cuenta. El usuario es '
                          'responsable de proporcionar información veraz, '
                          'mantener actualizados sus datos y resguardar la '
                          'confidencialidad de sus credenciales de acceso.',
                    ),
                    _TermsSection(
                      title: '5. Reservas, pagos y servicios ofrecidos',
                      body:
                          'Courtly facilita la interacción entre usuarios, '
                          'canchas deportivas y entrenadores independientes. '
                          'La disponibilidad, condiciones del servicio, '
                          'precios y cumplimiento de las actividades '
                          'ofrecidas podrán depender de cada proveedor o '
                          'profesional registrado en la plataforma.',
                    ),
                    _TermsSection(
                      title: '6. Propiedad intelectual',
                      body:
                          'Todo el contenido de Courtly, incluyendo nombre '
                          'comercial, diseño, interfaz, elementos visuales, '
                          'funcionalidades, textos y demás materiales '
                          'asociados, está protegido por la normativa '
                          'aplicable sobre propiedad intelectual. No está '
                          'permitido copiar, distribuir o reutilizar dicho '
                          'contenido sin autorización previa.',
                    ),
                    _TermsSection(
                      title: '7. Limitación de responsabilidad',
                      body:
                          'Courtly no garantiza que la plataforma esté libre '
                          'de interrupciones o errores en todo momento. '
                          'Tampoco será responsable por daños indirectos, '
                          'pérdida de oportunidades, conflictos entre usuarios '
                          'o incumplimientos atribuibles a terceros, en la '
                          'medida permitida por la legislación aplicable.',
                    ),
                    _TermsSection(
                      title: '8. Protección de datos',
                      body:
                          'El tratamiento de los datos personales se rige '
                          'por nuestra Política de Privacidad. Al utilizar la '
                          'plataforma, el usuario reconoce haber leído dicha '
                          'política y entender cómo Courtly recopila y utiliza '
                          'la información.',
                    ),
                    _TermsSection(
                      title: '9. Modificaciones',
                      body:
                          'Courtly podrá actualizar estos Términos y '
                          'Condiciones cuando resulte necesario. Cualquier '
                          'modificación relevante será publicada en esta '
                          'página y entrará en vigor desde su publicación o '
                          'desde la fecha que se indique expresamente.',
                    ),
                    _TermsSection(
                      title: '10. Legislación aplicable',
                      body:
                          'Estos términos se interpretarán de acuerdo con la '
                          'legislación aplicable en la jurisdicción '
                          'correspondiente a la operación de la plataforma. '
                          'Cualquier controversia será resuelta por las '
                          'autoridades o tribunales competentes según '
                          'corresponda.',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Aceptar términos'),
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

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          _TermsParagraph(body),
        ],
      ),
    );
  }
}

class _TermsParagraph extends StatelessWidget {
  final String text;

  const _TermsParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        height: 1.45,
      ),
    );
  }
}
