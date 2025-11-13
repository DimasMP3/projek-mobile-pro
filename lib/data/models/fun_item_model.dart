class FunItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl; // resolved from backend assets endpoint
  final String? linkUrl;
  final String status;
  final String createdAt;

  FunItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.linkUrl,
    required this.status,
    required this.createdAt,
  });

  factory FunItem.fromJson(Map<String, dynamic> j, {String baseUrl = ''}) {
    final imageAssetId = (j['imageAssetId'] as num?)?.toInt();
    final resolved = imageAssetId != null && baseUrl.isNotEmpty
        ? "$baseUrl/assets/$imageAssetId"
        : null;
    return FunItem(
      id: (j['id'] as num?)?.toInt().toString() ?? '0',
      title: j['title']?.toString() ?? '-',
      subtitle: j['subtitle']?.toString(),
      description: j['description']?.toString(),
      imageUrl: resolved,
      linkUrl: j['linkUrl']?.toString(),
      status: j['status']?.toString() ?? 'active',
      createdAt: j['createdAt']?.toString() ?? '',
    );
  }
}

