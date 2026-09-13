const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.url}`);
  next();
});

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'ghinaroot',
  database: 'db_blog_app'
});

db.connect((err) => {
  if (err) {
    console.error('Koneksi database gagal:', err.message);
    return;
  }
  console.log('Terhubung ke database MySQL db_blog_app');
});

app.get('/', (req, res) => {
  res.status(200).json({
    message: 'API Blog Travel Indonesia berjalan!',
    endpoints: {
      articles: '/api/articles',
      posts: '/api/posts',
      categories: '/api/categories'
    }
  });
});

app.get('/api/categories', (req, res) => {
  const sql = 'SELECT * FROM categories';
  db.query(sql, (err, results) => {
    if (err) {
      console.log('Gagal ambil kategori:', err.message);
      return res.status(500).json({ message: 'Internal Server Error', error: err.message });
    }
    console.log(`Berhasil ambil ${results.length} kategori`);
    res.status(200).json({ status: 'success', data: results });
  });
});

const getAllPosts = (req, res) => {
  const sql = `
    SELECT posts.*, categories.name AS category_name
    FROM posts
    LEFT JOIN categories ON posts.category_id = categories.id
    ORDER BY posts.id DESC
  `;
  db.query(sql, (err, results) => {
    if (err) {
      console.log('Gagal ambil artikel:', err.message);
      return res.status(500).json({ message: 'Internal Server Error', error: err.message });
    }
    console.log(`Berhasil ambil ${results.length} artikel`);
    res.status(200).json({ status: 'success', data: results });
  });
};

app.get('/api/posts', getAllPosts);
app.get('/api/articles', getAllPosts);

app.get('/api/posts/:id', (req, res) => {
  const { id } = req.params;
  const sql = `
    SELECT posts.*, categories.name AS category_name
    FROM posts
    LEFT JOIN categories ON posts.category_id = categories.id
    WHERE posts.id = ?
  `;
  db.query(sql, [id], (err, results) => {
    if (err) {
      console.log('Gagal ambil artikel:', err.message);
      return res.status(500).json({ message: 'Internal Server Error', error: err.message });
    }
    if (results.length === 0) {
      console.log(`Artikel id ${id} tidak ditemukan`);
      return res.status(404).json({ message: 'Artikel tidak ditemukan' });
    }
    console.log(`Berhasil ambil artikel id ${id}`);
    res.status(200).json({ status: 'success', data: results[0] });
  });
});

app.post('/api/posts', (req, res) => {
  const { title, content, category_id } = req.body;

  if (!title || !content || !category_id) {
    console.log('Gagal tambah: data tidak lengkap');
    return res.status(400).json({ message: 'Title, content, dan category_id wajib diisi' });
  }

  const sql = 'INSERT INTO posts (title, content, category_id) VALUES (?, ?, ?)';
  db.query(sql, [title, content, category_id], (err, result) => {
    if (err) {
      console.log('Gagal tambah artikel:', err.message);
      return res.status(500).json({ message: 'Gagal membuat artikel', error: err.message });
    }

    console.log(`Artikel ditambahkan: "${title}" (id: ${result.insertId})`);
    res.status(201).json({
      status: 'success',
      message: 'Artikel berhasil dibuat',
      data: { id: result.insertId, title, content, category_id }
    });
  });
});

app.put('/api/posts/:id', (req, res) => {
  const { id } = req.params;
  const { title, content, category_id } = req.body;

  if (!title || !content || !category_id) {
    console.log('Gagal update: data tidak lengkap');
    return res.status(400).json({ message: 'Title, content, dan category_id wajib diisi' });
  }

  const sql = 'UPDATE posts SET title = ?, content = ?, category_id = ? WHERE id = ?';
  db.query(sql, [title, content, category_id, id], (err, result) => {
    if (err) {
      console.log('Gagal update artikel:', err.message);
      return res.status(500).json({ message: 'Gagal memperbarui artikel', error: err.message });
    }
    if (result.affectedRows === 0) {
      console.log(`Artikel id ${id} tidak ditemukan`);
      return res.status(404).json({ message: 'Artikel tidak ditemukan' });
    }

    console.log(`Artikel diupdate (id: ${id}) - "${title}"`);
    res.status(200).json({ status: 'success', message: 'Artikel berhasil diperbarui' });
  });
});

app.delete('/api/posts/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM posts WHERE id = ?';
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.log('Gagal hapus artikel:', err.message);
      return res.status(500).json({ message: 'Gagal menghapus artikel', error: err.message });
    }
    if (result.affectedRows === 0) {
      console.log(`Artikel id ${id} tidak ditemukan`);
      return res.status(404).json({ message: 'Artikel tidak ditemukan' });
    }

    console.log(`Artikel dihapus (id: ${id})`);
    res.status(200).json({ status: 'success', message: 'Artikel berhasil dihapus' });
  });
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});