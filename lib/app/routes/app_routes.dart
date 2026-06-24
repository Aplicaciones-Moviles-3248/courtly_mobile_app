import 'package:flutter/material.dart';

import '../../contexts/courts/presentation/screens/court_detail_screen.dart';
import '../../contexts/courts/presentation/screens/court_search_screen.dart';
import '../../contexts/payments/presentation/screens/payments_screen.dart';
import '../../contexts/users/presentation/screens/edit_profile_screen.dart';
import '../../contexts/iam/presentation/screens/sign_in_screen.dart';
import '../../contexts/users/presentation/screens/profile_screen.dart';
import '../../contexts/bookings/presentation/screens/create_booking_screen.dart';
import '../../contexts/bookings/presentation/screens/my_bookings_screen.dart';

class AppRoutes {
  static const String signIn = '/sign-in';
  static const String home = '/home';
  static const String courts = '/courts';
  static const String courtDetail = '/courts/detail';
  static const String matches = '/matches';
  static const String payments = '/payments';
  static const String profile = '/users/profile';
  static const String editProfile = '/users/edit-profile';
  static const String createBooking = '/bookings/create';
  static const String myBookings    = '/bookings/my';

  static Map<String, WidgetBuilder> get routes {
    return {
      signIn: (context) => const SignInScreen(),
      home: (context) => const CourtSearchScreen(),
      courts: (context) => const CourtSearchScreen(),
      matches: (context) => const CourtSearchScreen(),
      payments: (context) => const PaymentsScreen(),
      courtDetail: (context) => const CourtDetailScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      createBooking: (context) => const CreateBookingScreen(),
      myBookings:    (context) => const MyBookingsScreen(),
    };
  }
}