import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  final Map? article;
  const FormPage({super.key, this.article});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;
  bool isSaving = false;
  bool isLoading = true;

  final String baseUrl = 'http://localhost:5000/api';
  bool get isEdit => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      titleController.text = widget.article!['title'] ?? '';
      contentController.text = widget.article!['content'] ?? '';
      selectedCategoryId = widget.article!['category_id'];
    }
    getCategories();
  }

  Future<void> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        categories = body['data'];
        selectedCategoryId ??= categories.isNotEmpty ? categories[0]['id'] : null;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveArticle() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi wajib diisi')),
      );
      return;
    }

    setState(() => isSaving = true);

    final body = jsonEncode({
      'title': titleController.text,
      'content': contentController.text,
      'category_id': selectedCategoryId,
    });

    final http.Response response;
    if (isEdit) {
      response = await http.put(
        Uri.parse('$baseUrl/posts/${widget.article!['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } else {
      response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    }

    setState(() => isSaving = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Artikel' : 'Tambah Artikel',
          style: const TextStyle(fontFamily: 'Dancing Script'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontFamily: 'Dancing Script'),
                    decoration: const InputDecoration(labelText: 'Judul'),
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories.map<DropdownMenuItem<int>>((cat) {
                      return DropdownMenuItem(
                        value: cat['id'],
                        child: Text(cat['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategoryId = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    style: const TextStyle(fontFamily: 'Oooh Baby'),
                    decoration: const InputDecoration(labelText: 'Isi Artikel'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSaving ? null : saveArticle,
                    child: Text(isEdit ? 'Update' : 'Simpan'),
                  ),
                ],
              ),
            ),
    );
  }
}