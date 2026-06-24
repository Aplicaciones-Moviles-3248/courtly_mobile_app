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
    final id = json['id'].toString();
    final price = _toDouble(json['pricePerHour']);

    return CourtModel(
      id: id,
      name: name,
      district: location,
      sport: type,
      description: 'Cancha de $type ubicada en $location, disponible para reservas en Courtly.',
      address: location,
      pricePerHour: price,
      availableSchedules: _buildTemporaryAvailableSchedules(id),
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: true,
    );
  }

  static int _buildTemporaryAvailableSchedules(String id) {
    final numericId = int.tryParse(id) ?? 1;

    if (numericId % 4 == 0) {
      return 0;
    }

    if (numericId % 3 == 0) {
      return 1;
    }

    if (numericId % 2 == 0) {
      return 2;
    }

    return 3;
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