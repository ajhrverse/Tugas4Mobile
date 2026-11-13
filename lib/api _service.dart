
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';

class ApiService {

  static const url =
      'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  Future<List<ArticleModel>> fetchMeals() async {

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data makanan');
    }

    final data = jsonDecode(response.body);

    final meals = data['meals'];

    if (meals == null) {
      return [];
    }

    return (meals as List)
        .map((item) => ArticleModel.fromJson(item))
        .toList();
  }
}
