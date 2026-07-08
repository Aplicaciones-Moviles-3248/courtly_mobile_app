import '../../domain/entities/training_court.dart';

class TrainingCourtModel extends TrainingCourt {
  const TrainingCourtModel({
    required super.id,
    required super.name,
    required super.location,
    required super.type,
    required super.imageUrl,
    required super.pricePerHour,
  });

  factory TrainingCourtModel.fromJson(Map<String, dynamic> json) {
    return TrainingCourtModel(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? 'Cancha',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      pricePerHour: _toDouble(json['pricePerHour']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse('${value ?? ''}') ?? 0;
  }
}
