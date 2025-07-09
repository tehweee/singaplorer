class Review {
  final String id;
  final int numericRating;
  final String? content;
  final String? userName;

  Review({
    required this.id,
    required this.numericRating,
    this.content,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      numericRating: json['numericRating'] ?? 0,
      content: json['content'],
      userName: json['userName'],
    );
  }
}

class DetailItinerary {
  final String description;
  final String reviewTotal;
  final String name;
  final String address;
  final String city;
  final String country;
  final String reviewStats;
  final String price;
  final List<Review> reviews;

  DetailItinerary({
    required this.description,
    required this.reviewTotal,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.reviewStats,
    required this.price,
    required this.reviews,
  });

  factory DetailItinerary.fromJson(Map<String, dynamic> json) {
    final reviewList = json['reviews'] as List? ?? [];
    return DetailItinerary(
      description: json['description'] ?? '',
      reviewTotal: json['reviewTotal'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      reviewStats: json['reviewStats'].toString(),
      price: json['price'].toString(),
      reviews: reviewList.map((r) => Review.fromJson(r)).toList(),
    );
  }
}
