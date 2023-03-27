import 'package:cryptonic/src/utils/resources/router/route_names.dart';
import 'package:cryptonic/src/presentation/screens/preview_screen.dart';
import 'package:flutter/material.dart';

class MainNavigation {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.preview:
        {
          return MaterialPageRoute(
            builder: (context) => PreviewScreen(),
          );
        }

      default:
    }
    return null;
  }
}
