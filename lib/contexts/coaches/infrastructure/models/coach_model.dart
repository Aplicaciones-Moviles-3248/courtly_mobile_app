import '../../domain/entities/coach.dart';

class CoachModel extends Coach {
  const CoachModel({
    required super.id,
    required super.name,
    required super.expertise,
    required super.phone,
    required super.userId,
    required super.availableSlots,
  });

  factory CoachModel.fromJson(
      Map<String, dynamic> json, {
        int availableSlots = 0,
      }) {
    return CoachModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Entrenador',
      expertise: json['expertise']?.toString() ?? 'Entrenamiento deportivo',
      phone: json['phone']?.toString() ?? '',
      userId: _toInt(json['userId']),
      availableSlots: availableSlots,
    );
  }

  CoachModel copyWith({
    int? availableSlots,
  }) {
    return CoachModel(
      id: id,
      name: name,
      expertise: expertise,
      phone: phone,
      userId: userId,
      availableSlots: availableSlots ?? this.availableSlots,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }
}