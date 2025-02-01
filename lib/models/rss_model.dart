import 'rss_category_model.dart';

class RssModel {
  final int id;
  final String title;
  final String url;
  final List<RssCategoryModel> categories;

  const RssModel({
    required this.id,
    required this.title,
    required this.url,
    this.categories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }

  factory RssModel.fromJson(Map<String, dynamic> json) {
    return RssModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => RssCategoryModel.fromJson(category))
              .toList() ??
          [],
    );
  }
}
