import 'package:flutter/material.dart';

import '../core/design_system/design_system.dart';
import 'app_bootstrap.dart';
import 'app_router.dart';

class MacGyverApp extends StatefulWidget {
  const MacGyverApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<MacGyverApp> createState() => _MacGyverAppState();
}

class _MacGyverAppState extends State<MacGyverApp> {
  late final _router = createRouter(widget.dependencies.authController);

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      child: MaterialApp.router(
        title: 'MacGyver Classroom',
        theme: McTheme.light(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
