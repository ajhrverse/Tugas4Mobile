
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
      title: 'Foodie Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
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

      if (_scrollController.offset > 250) {
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

  // Fungsi refresh data makanan
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

      // APP BAR
      appBar: AppBar(
        title: const Text(
          'Foodie Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: const Icon(
          Icons.restaurant_menu,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 2,
      ),

      // BODY
      body: FutureBuilder<List<ArticleModel>>(
        future: meals,
        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gagal memuat makanan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: refreshMeals,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? [];

          // Data kosong
          if (data.isEmpty) {
            return const Center(
              child: Text('Tidak ada makanan'),
            );
          }

          // Daftar makanan
          return RefreshIndicator(
            color: Colors.deepOrange,
            onRefresh: refreshMeals,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {

                final meal = data[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 18),
                  elevation: 3,
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // GAMBAR MAKANAN
                      if (meal.urlToImage != null)
                        Image.network(
                          meal.urlToImage!,
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              height: 190,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),

                      // INFORMASI MAKANAN
                      Padding(
                        padding: const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // NAMA MAKANAN
                            Text(
                              meal.judul,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // HARGA
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  color: Colors.deepOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),

                                Text(
                                  'Rp ${meal.harga}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // DESKRIPSI
                            Text(
                              meal.deskripsi,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.grey.shade700,
                              ),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
          );
        },
      ),

      // TOMBOL KEMBALI KE ATAS
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      floatingActionButton: showTopButton
          ? FloatingActionButton(
              heroTag: 'backToTop',
              onPressed: scrollToTop,
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              tooltip: 'Kembali ke atas',
              child: const Icon(
                Icons.keyboard_arrow_up,
                size: 32,
              ),
            )
          : null,

    );
  }
}
