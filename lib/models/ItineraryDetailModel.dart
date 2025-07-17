class Review {
  final String id;
  final int numericRating; // This is what Flutter model expects
  final String? content;
  final String? userName;
  final String? userCountry;
  final String? userAvatar;
  final String? language;
  final int? epochMs;
  final List<String> travelPartnerTypes;

  Review({
    required this.id,
    required this.numericRating,
    this.content,
    this.userName,
    this.userCountry,
    this.userAvatar,
    this.language,
    this.epochMs,
    required this.travelPartnerTypes,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Correctly extracts user data from a nested 'user' map
    final review = json['reviews'] as Map<String, dynamic>? ?? {};

    return Review(
      id: json['id']?.toString() ?? '',
      numericRating:
          (json['numericRating'] as num?)?.toInt() ??
          0, // Correctly reads numericRating
      content: json['content']?.toString(),
      userName: json['userName']?.toString(), // Fetches from nested 'user'
      userCountry: json['userCountry']
          ?.toString(), // Fetches from nested 'user'
      userAvatar: json['userAvatar']?.toString(), // Fetches from nested 'user'
      language: json['language']?.toString(),
      epochMs: (json['epochMs'] as num?)?.toInt(),
      travelPartnerTypes:
          (json['travelPartnerTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class DetailItinerary {
  final String description;
  final int reviewTotal; // Changed to int
  final String name;
  final String address;
  final String city;
  final String country;
  final double reviewStats; // Changed to double
  final double price; // Changed to double
  final List<String> photos; // Added for the list of small image URLs
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
    required this.photos, // Added
    required this.reviews,
  });

  factory DetailItinerary.fromJson(Map<String, dynamic> json) {
    final reviewList = json['reviews'] as List? ?? [];
    final photoUrls = json['photos'] as List? ?? []; // Added for photos

    return DetailItinerary(
      description: json['description']?.toString() ?? '',
      reviewTotal:
          (json['reviewTotal'] as num?)?.toInt() ?? 0, // Handle num to int
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      reviewStats:
          (json['reviewStats'] as num?)?.toDouble() ??
          0.0, // Handle num to double
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Handle num to double
      photos: photoUrls
          .map((e) => e.toString())
          .toList(), // Map each item to string for photo URLs
      reviews: reviewList
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
