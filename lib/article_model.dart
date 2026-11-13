
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
      judul: json['strMeal'] ?? 'Tanpa Nama',
      deskripsi: json['strInstructions'],
      urlToImage: json['strMealThumb'],
    );

  }
}
