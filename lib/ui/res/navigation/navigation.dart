import 'package:cryptonic/ui/res/navigation/route_names.dart';
import 'package:cryptonic/ui/screens/preview_screen.dart';
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
