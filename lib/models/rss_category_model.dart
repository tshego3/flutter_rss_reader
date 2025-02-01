class RssCategoryModel {
  final double id;
  final String title;
  final String url;

  const RssCategoryModel({
    required this.id,
    required this.title,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
    };
  }

  factory RssCategoryModel.fromJson(Map<String, dynamic> json) {
    return RssCategoryModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
    );
  }
}
