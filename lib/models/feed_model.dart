class FeedModel {
  final DateTime pubdate;
  final String title;
  final String description;
  final String url;

  const FeedModel({
    required this.pubdate,
    required this.title,
    required this.description,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'pubdate': pubdate.toIso8601String(),
      'title': title,
      'description': description,
      'url': url,
    };
  }

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      pubdate: DateTime.parse(json['pubdate']),
      title: json['title'],
      description: json['description'],
      url: json['url'],
    );
  }
}
