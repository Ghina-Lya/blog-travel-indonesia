import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map article;
  const DetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Artikel',
          style: TextStyle(fontFamily: 'Dancing Script'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? '',
              style: const TextStyle(
                fontFamily: 'Dancing Script',
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kategori: ${article['category_name'] ?? '-'}',
              style: const TextStyle(
                fontFamily: 'Oooh Baby',
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article['content'] ?? '',
              style: const TextStyle(
                fontFamily: 'Oooh Baby',
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}