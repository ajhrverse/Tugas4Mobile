
import 'package:flutter/material.dart';
import 'api _service.dart';
import 'article_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita kuliiner',
      debugShowCheckedModeBanner: false,
      home: const NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

  late Future<List<ArticleModel>> articles;

  // Controller untuk mengatur scroll
  final ScrollController _scrollController = ScrollController();

  // Status tombol kembali ke atas
  bool showTopButton = false;

  @override
  void initState() {
    super.initState();

    articles = ApiService().fetchArticles();

    //  posisi scroll
    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!showTopButton) {
          setState(() {
            showTopButton = true;
          });
        }
      } else {
        if (showTopButton) {
          setState(() {
            showTopButton = false;
          });
        }
      }
    });
  }

  // Fungsi pull-to-refresh
  Future<void> refreshArticles() async {
    setState(() {
      articles = ApiService().fetchArticles();
    });

    try {
      await articles;
    } catch (_) {
      // Error ditampilkan melalui FutureBuilder
    }
  }

  // Fungsi kembali ke atas
  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
appBar: AppBar(
  title: const Text('Berita Kuliner Terkini'),
  leading: const Icon(Icons.newspaper_sharp),
  centerTitle: true,
  backgroundColor: Colors.black,
  foregroundColor: Colors.white,

  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Refresh Berita',
      onPressed: refreshArticles,
    ),
  ],
),


      body: FutureBuilder<List<ArticleModel>>(
        future: articles,
        builder: (context, snapshot) {

          // Kondisi loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Kondisi error
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error : ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          // Jika tidak ada berita
          if (data.isEmpty) {
            return const Center(
              child: Text('Tidak ada Berita kuliner'),
            );
          }

          // Menampilkan daftar berita dan pull-to-refresh
          return RefreshIndicator(
            onRefresh: refreshArticles,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {

                final article = data[index];

                return Card(
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    leading: article.urlToImage != null
                        ? Image.network(
                            article.urlToImage!,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.newspaper),

                    title: Text(article.judul),

                    subtitle: Text(
                      article.deskripsi ?? 'Tidak ada deskripsi',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // Tombol kembali ke atas
      floatingActionButton: showTopButton
          ? FloatingActionButton(
              onPressed: scrollToTop,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}