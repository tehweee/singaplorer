class Itinerary {
  final String name;
  final String slug;
  final String shortDescription;
  final String price;
  Itinerary({
    required this.name,
    required this.slug,
    required this.shortDescription,
    required this.price,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      name: json['name'] ?? 'Unknown Plan',
      slug: json['slug'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      price: json['price'].toString(), 
    );
  }
}
