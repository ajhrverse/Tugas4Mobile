
class ArticleModel {

  final String judul;
  final int harga;
  final String deskripsi;
  final String? urlToImage;

  ArticleModel({
    required this.judul,
    required this.harga,
    required this.deskripsi,
    this.urlToImage,
  });

  factory ArticleModel.fromJson(
    Map<String, dynamic> json, {
    required int harga,
  }) {

    return ArticleModel(
      judul: json['strMeal'] ?? 'Nama Makanan',
      harga: harga,
      deskripsi: json['strInstructions'] ?? 'Tidak ada deskripsi',
      urlToImage: json['strMealThumb'],
    );
  }
}
