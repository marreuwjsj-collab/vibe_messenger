import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomePage(),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _NotFoundPage(),
        );
    }
  }
}

final class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Страница не найдена')),
      );
}
