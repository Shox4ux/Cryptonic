import 'package:cryptonic/core/domain/crypto_model.dart';
import 'package:cryptonic/ui/res/navigation/route_names.dart';
import 'package:cryptonic/ui/screens/preview_screen.dart';
import 'package:flutter/material.dart';

class MainNavigation {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.preview:
        {
          final model = settings.arguments as List<CryptoModel>;
          return MaterialPageRoute(
            builder: (context) => PreviewScreen(
              model: model,
            ),
          );
        }

      default:
    }
    return null;
  }
}
