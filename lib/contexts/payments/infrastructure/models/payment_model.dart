import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.paymentDate,
    required super.status,
    required super.contextType,
    required super.bookingId,
    required super.trainingSessionId,
    required super.userId,
    required super.userName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return PaymentModel(
      id: _toInt(json['id']),
      amount: _toDouble(json['amount']),
      paymentDate: _toDateTime(json['paymentDate']),
      status: json['status']?.toString() ?? '',
      contextType: json['contextType']?.toString() ?? '',
      bookingId: json['bookingId'] == null ? null : _toInt(json['bookingId']),
      trainingSessionId:
          json['trainingSessionId'] == null ? null : _toInt(json['trainingSessionId']),
      userId: _toInt(user?['id']),
      userName: user?['name']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
