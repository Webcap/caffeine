class PremiumPlan {
  final String id;
  final String title;
  final String price;
  final String period;
  final bool isPopular;
  final String? saveText;
  final int sortOrder;
  final String? revenueCatIdentifier;

  PremiumPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
    this.saveText,
    required this.sortOrder,
    this.revenueCatIdentifier,
  });

  factory PremiumPlan.fromJson(Map<String, dynamic> json) {
    return PremiumPlan(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      period: json['period'],
      isPopular: json['is_popular'] ?? false,
      saveText: json['save_text'],
      sortOrder: json['sort_order'] ?? 0,
      revenueCatIdentifier: json['revenue_cat_identifier'],
    );
  }
}

class PremiumFeature {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String colorHex;
  final int sortOrder;

  PremiumFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.sortOrder,
  });

  factory PremiumFeature.fromJson(Map<String, dynamic> json) {
    return PremiumFeature(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['icon_name'],
      colorHex: json['color_hex'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
