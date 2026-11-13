
class ArticleModel {

  final String judul;
  final String? deskripsi;
  final String? urlToImage;

  ArticleModel({
    required this.judul,
    this.deskripsi,
    this.urlToImage,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      judul: json['title'] ?? "Tanpa Judul",
      deskripsi: json['description'],
      urlToImage: json['urlToImage'],
    );
  }
}