import 'package:flutter/material.dart';

import '../../contexts/coaches/presentation/screens/available_coaches_screen.dart';
import '../../contexts/courts/presentation/screens/court_detail_screen.dart';
import '../../contexts/courts/presentation/screens/court_search_screen.dart';
import '../../contexts/iam/presentation/screens/sign_in_screen.dart';
import '../../contexts/payments/presentation/screens/payments_screen.dart';
import '../../contexts/users/presentation/screens/edit_profile_screen.dart';
import '../../contexts/users/presentation/screens/profile_screen.dart';
import '../../contexts/coaches/presentation/screens/coach_detail_screen.dart';
import '../../contexts/coaches/presentation/screens/coach_review_screen.dart';
import '../../contexts/coaches/presentation/screens/coach_session_request_screen.dart';

class AppRoutes {
  static const String signIn = '/sign-in';
  static const String home = '/home';
  static const String courts = '/courts';
  static const String courtDetail = '/courts/detail';
  static const String coaches = '/coaches';
  static const String matches = '/matches';
  static const String payments = '/payments';
  static const String profile = '/users/profile';
  static const String editProfile = '/users/edit-profile';
  static const String coachDetail = '/coaches/detail';
  static const String coachReview = '/coaches/review';
  static const String coachSessionRequest = '/coaches/session-request';

  static Map<String, WidgetBuilder> get routes {
    return {
      signIn: (context) => const SignInScreen(),
      home: (context) => const CourtSearchScreen(),
      courts: (context) => const CourtSearchScreen(),
      courtDetail: (context) => const CourtDetailScreen(),
      coaches: (context) => const AvailableCoachesScreen(),
      matches: (context) => const CourtSearchScreen(),
      payments: (context) => const PaymentsScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      coachDetail: (context) => const CoachDetailScreen(),
      coachReview: (context) => const CoachReviewScreen(),
      coachSessionRequest: (context) => const CoachSessionRequestScreen(),
    };
  }
}