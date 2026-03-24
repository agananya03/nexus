import 'package:flutter/material.dart';
import 'core/router.dart';

void main() {
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF6C63FF),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Inter',
            ),
      ),
      routerConfig: appRouter,
    );
  }
}
