import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/notifiers/auth_notifier.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/notes/screens/notes_list_screen.dart';
import '../features/notes/screens/upload_note_screen.dart';

import '../features/internships/screens/internship_list_screen.dart';
import '../features/internships/screens/internship_detail_screen.dart';
import '../features/events/screens/event_list_screen.dart';
import '../features/events/screens/event_detail_screen.dart';
import '../features/books/screens/book_list_screen.dart';
import '../features/books/screens/book_detail_screen.dart';
import '../features/books/screens/list_book_screen.dart';
import '../features/doubt_solver/screens/doubt_list_screen.dart';
import '../features/doubt_solver/screens/doubt_detail_screen.dart';
import '../features/doubt_solver/screens/post_doubt_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('ProfileScreen')));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/internships',
    redirect: (context, state) {
      if (authState.isLoading) return null;
      
      final isAuth = authState.value != null;
      final isGoingToLogin = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }
      if (isAuth && (state.matchedLocation == '/' || isGoingToLogin)) {
        return '/internships';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child, location: state.uri.toString()),
        routes: [
          GoRoute(
            path: '/internships',
            builder: (context, state) => const InternshipListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => InternshipDetailScreen(
                    internshipId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => EventDetailScreen(
                    eventId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/books',
            builder: (context, state) => const BookListScreen(),
            routes: [
              GoRoute(
                path: 'list',
                builder: (context, state) => const ListBookScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    BookDetailScreen(bookId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/doubts',
            builder: (context, state) => const DoubtListScreen(),
            routes: [
              GoRoute(
                path: 'post',
                builder: (context, state) => const PostDoubtScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    DoubtDetailScreen(doubtId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
      // Other standalone routes (Notes, Profile etc)
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotesListScreen(),
      ),
      GoRoute(
        path: '/notes/upload',
        builder: (context, state) => const UploadNoteScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  int get _selectedIndex {
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/books')) return 2;
    if (location.startsWith('/doubts')) return 3;
    return 0; // internships
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF1A1D27),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/internships');
              break;
            case 1:
              context.go('/events');
              break;
            case 2:
              context.go('/books');
              break;
            case 3:
              context.go('/doubts');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Internships',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'Doubts',
          ),
        ],
      ),
    );
  }
}
