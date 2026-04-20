import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/app_toast.dart';
import 'book_detail_screen.dart';
import 'list_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});
  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _books = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getBooks();
      setState(() => _books = data);
    } catch (e) {
      if (mounted) showAppToast(context, 'Failed to load books: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _conditionColor(String? condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.amberAccent;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Book Marketplace',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('List a Book', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListBookScreen()),
          );
          _fetch();
        },
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _books.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book,
                  title: 'No books available',
                  subtitle: 'Be the first to list a book!',
                )
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _books.length,
                    itemBuilder: (ctx, i) {
                      final book = _books[i] as Map<String, dynamic>;
                      final condition = book['condition'] as String?;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(
                                bookId: book['book_id']),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D27),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF6C63FF)
                                    .withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                                child: book['image_url'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: book['image_url'],
                                        height: 130,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          height: 130,
                                          color: const Color(0xFF0F1117),
                                          child: const Icon(Icons.book,
                                              color: Colors.white24, size: 40),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          height: 130,
                                          color: const Color(0xFF0F1117),
                                          child: const Icon(Icons.book,
                                              color: Colors.white24, size: 40),
                                        ),
                                      )
                                    : Container(
                                        height: 130,
                                        color: const Color(0xFF0F1117),
                                        child: const Icon(Icons.book,
                                            color: Colors.white24, size: 40),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['title'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    // Condition badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _conditionColor(condition)
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: _conditionColor(condition)
                                                .withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        condition ?? '',
                                        style: TextStyle(
                                            color: _conditionColor(condition),
                                            fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹ ${book['price']?.toStringAsFixed(0) ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
