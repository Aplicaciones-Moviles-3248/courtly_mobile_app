enum NotificationType {
  bookingCreated,
  bookingConfirmed,
  bookingCancelled,
  trainingSessionRequested,
  trainingSessionAccepted,
  trainingSessionRejected,
  trainingSessionCancelled,
  paymentConfirmed,
  reviewEnabled,
}

extension NotificationTypeMapper on NotificationType {
  static NotificationType fromString(String value) {
    switch (value) {
      case 'BOOKING_CREATED':
        return NotificationType.bookingCreated;

      case 'BOOKING_CONFIRMED':
        return NotificationType.bookingConfirmed;

      case 'BOOKING_CANCELLED':
        return NotificationType.bookingCancelled;

      case 'TRAINING_SESSION_REQUESTED':
        return NotificationType.trainingSessionRequested;

      case 'TRAINING_SESSION_ACCEPTED':
        return NotificationType.trainingSessionAccepted;

      case 'TRAINING_SESSION_REJECTED':
        return NotificationType.trainingSessionRejected;

      case 'TRAINING_SESSION_CANCELLED':
        return NotificationType.trainingSessionCancelled;

      case 'PAYMENT_CONFIRMED':
        return NotificationType.paymentConfirmed;

      case 'REVIEW_ENABLED':
        return NotificationType.reviewEnabled;

      default:
        throw Exception('Unknown notification type: $value');
    }
  }

  String get backendValue {
    switch (this) {
      case NotificationType.bookingCreated:
        return 'BOOKING_CREATED';

      case NotificationType.bookingConfirmed:
        return 'BOOKING_CONFIRMED';

      case NotificationType.bookingCancelled:
        return 'BOOKING_CANCELLED';

      case NotificationType.trainingSessionRequested:
        return 'TRAINING_SESSION_REQUESTED';

      case NotificationType.trainingSessionAccepted:
        return 'TRAINING_SESSION_ACCEPTED';

      case NotificationType.trainingSessionRejected:
        return 'TRAINING_SESSION_REJECTED';

      case NotificationType.trainingSessionCancelled:
        return 'TRAINING_SESSION_CANCELLED';

      case NotificationType.paymentConfirmed:
        return 'PAYMENT_CONFIRMED';

      case NotificationType.reviewEnabled:
        return 'REVIEW_ENABLED';
    }
  }
}