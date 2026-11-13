
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
      title: 'Aplikasi Makanan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
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

  late Future<List<ArticleModel>> meals;

  final ScrollController _scrollController = ScrollController();

  bool showTopButton = false;

  @override
  void initState() {
    super.initState();

    meals = ApiService().fetchMeals();

    // Mendeteksi posisi scroll
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
  Future<void> refreshMeals() async {
    setState(() {
      meals = ApiService().fetchMeals();
    });

    try {
      await meals;
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
        title: const Text('Daftar Makanan'),
        leading: const Icon(Icons.restaurant),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<List<ArticleModel>>(
        future: meals,
        builder: (context, snapshot) {

          Widget content;

          // Kondisi loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            content = const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Kondisi error
          else if (snapshot.hasError) {
            content = Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          else {
            final data = snapshot.data ?? [];

            // Kondisi data kosong
            if (data.isEmpty) {
              content = const Center(
                child: Text('Tidak ada makanan'),
              );
            }

            // Menampilkan daftar makanan
            else {
              content = ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final meal = data[index];

                  return Card(
                    margin: const EdgeInsets.all(15),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),

                      leading: meal.urlToImage != null
                          ? Image.network(
                              meal.urlToImage!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.restaurant),

                      title: Text(
                        meal.judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        meal.deskripsi ?? 'Tidak ada deskripsi',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              );
            }
          }

          return RefreshIndicator(
            onRefresh: refreshMeals,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: content,
                ),
              ],
            ),
          );
        },
      ),

      // Tombol kembali ke atas
      floatingActionButton: showTopButton
          ? FloatingActionButton(
              onPressed: scrollToTop,
              backgroundColor: Colors.orange,
              foregroundColor: const Color.fromARGB(255, 61, 23, 23),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
