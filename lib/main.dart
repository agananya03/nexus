import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: NexusApp(),
    ),
  );
}

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF6C63FF),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
      ),
      routerConfig: router,
    );
  }
}
