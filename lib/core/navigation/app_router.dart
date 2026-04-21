import 'package:flutter/material.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/method_selection_screen.dart';
import '../../ui/screens/solver_screen.dart';
import '../../ui/screens/splash_screen.dart';
import '../providers/solver_provider.dart';

/// Centralized route names and navigation helper.
class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String methodSelection = '/methods';
  static const String solver = '/solver';

  /// Generates all named routes for the app.
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: routeSettings);

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: routeSettings);
      
      case methodSelection:
        final category = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MethodSelectionScreen(category: category),
          settings: routeSettings,
        );
        
      case solver:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SolverScreen(
            method: args['method'] as NumericalMethod,
            methodName: args['name'] as String,
            category: args['category'] as String,
          ),
          settings: routeSettings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404'))),
          settings: routeSettings,
        );
    }
  }
}
