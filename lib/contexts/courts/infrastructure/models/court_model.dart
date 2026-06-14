import '../../domain/entities/court.dart';

class CourtModel extends Court {
  const CourtModel({
    required super.id,
    required super.name,
    required super.district,
    required super.sport,
    required super.description,
    required super.address,
    required super.pricePerHour,
    required super.availableSchedules,
    required super.imageUrl,
    required super.isAvailable,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? '';
    final type = json['type'] ?? '';
    final name = json['name'] ?? '';

    return CourtModel(
      id: json['id'].toString(),
      name: name,
      district: location,
      sport: type,
      description: 'Cancha de $type ubicada en $location, disponible para reservas en Courtly.',
      address: location,
      pricePerHour: _toDouble(json['pricePerHour']),
      availableSchedules: 0,
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: true,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}