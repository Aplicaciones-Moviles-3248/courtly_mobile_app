import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ReviewFormResult {
  final int score;
  final String comment;

  const ReviewFormResult({required this.score, required this.comment});
}

class ReviewFormBottomSheet extends StatefulWidget {
  final String courtName;

  const ReviewFormBottomSheet({super.key, required this.courtName});

  @override
  State<ReviewFormBottomSheet> createState() => _ReviewFormBottomSheetState();
}

class _ReviewFormBottomSheetState extends State<ReviewFormBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _score = 0;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();

    if (_score < 1 || _score > 5) {
      setState(() => _errorText = 'Selecciona una calificacion.');
      return;
    }

    if (comment.isEmpty) {
      setState(() => _errorText = 'Escribe un comentario.');
      return;
    }

    Navigator.pop(context, ReviewFormResult(score: _score, comment: comment));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Valorar cancha',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.courtName,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(5, (index) {
                final value = index + 1;

                return IconButton(
                  tooltip: '$value estrellas',
                  onPressed: () => setState(() {
                    _score = value;
                    _errorText = null;
                  }),
                  icon: Icon(
                    value <= _score ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Cuéntanos cómo fue tu experiencia',
                filled: true,
                fillColor: const Color(0xFFF7FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Publicar reseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
