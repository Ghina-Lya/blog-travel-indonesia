import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detail.dart';
import 'form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List articles = [];
  bool isLoading = true;

  final String baseUrl = 'http://localhost:5000/api';

  @override
  void initState() {
    super.initState();
    getArticles();
  }

  Future<void> getArticles() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('$baseUrl/articles'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        articles = body['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteArticle(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) getArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blog Travel Indonesia',
          style: TextStyle(fontFamily: 'Dancing Script', fontSize: 22),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: getArticles),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final item = articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      item['title'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Dancing Script',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item['category_name'] ?? '',
                      style: const TextStyle(fontFamily: 'Oooh Baby', fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(article: item),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormPage(article: item),
                              ),
                            );
                            getArticles();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteArticle(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPage()),
          );
          getArticles();
        },
      ),
    );
  }
}