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
  matchCreated,
  matchJoined,
  matchParticipantJoined,
  matchCancelled,
  matchJoinApproved
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

      case 'MATCH_CREATED':
        return NotificationType.matchCreated;

      case 'MATCH_JOINED':
        return NotificationType.matchJoined;

      case 'MATCH_PARTICIPANT_JOINED':
        return NotificationType.matchParticipantJoined;

      case 'MATCH_CANCELLED':
        return NotificationType.matchCancelled;

      case 'MATCH_JOIN_APPROVED':
        return NotificationType.matchJoinApproved;

      default:
        return NotificationType.bookingCreated;
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

      case NotificationType.matchCreated:
        return 'MATCH_CREATED';

      case NotificationType.matchJoined:
        return 'MATCH_JOINED';

      case NotificationType.matchParticipantJoined:
        return 'MATCH_PARTICIPANT_JOINED';

      case NotificationType.matchCancelled:
        return 'MATCH_CANCELLED';

      case NotificationType.matchJoinApproved:
        return 'MATCH_JOIN_APPROVED';
    }
  }
}