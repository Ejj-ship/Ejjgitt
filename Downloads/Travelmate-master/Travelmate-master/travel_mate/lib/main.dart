import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';
import 'screens/home_screen.dart';
import 'screens/trip_details_screen.dart';
import 'screens/add_edit_trip_screen.dart';
import 'screens/add_edit_destination_screen.dart';
import 'screens/add_edit_activity_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TravelMateApp());
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TripProvider(),
      child: MaterialApp(
        title: 'TravelMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _buildPageRoute(
                const HomeScreen(),
                settings,
              );
            case '/trip-details':
              return _buildPageRoute(
                const TripDetailsScreen(),
                settings,
              );
            case '/add-trip':
              return _buildPageRoute(
                const AddEditTripScreen(),
                settings,
              );
            case '/edit-trip':
              return _buildPageRoute(
                const AddEditTripScreen(isEditing: true),
                settings,
              );
            case '/add-destination':
              return _buildPageRoute(
                const AddEditDestinationScreen(),
                settings,
              );
            case '/edit-destination':
              return _buildPageRoute(
                const AddEditDestinationScreen(isEditing: true),
                settings,
              );
            case '/add-activity':
              return _buildPageRoute(
                const AddEditActivityScreen(),
                settings,
              );
            case '/edit-activity':
              return _buildPageRoute(
                const AddEditActivityScreen(isEditing: true),
                settings,
              );
            default:
              return _buildPageRoute(
                const HomeScreen(),
                settings,
              );
          }
        },
      ),
    );
  }

  PageRoute<dynamic> _buildPageRoute(Widget page, RouteSettings settings) {
    return CupertinoPageRoute(
      settings: settings,
      builder: (context) => page,
    );
  }
}

