// models/HotelDetailModel.dart
class HotelDetail {
  final String
  hotelID; // Ensure this is String if your Flutter expects it, or change type below
  final String name;
  final String arrivalDate;
  final String departureDate;
  final double? latitude;
  final double? longitude;
  final String address;
  final String city;
  final double totalPrice;
  final String currency;
  final int reviewCount; // Make sure this is int
  final double reviewScore; // Make sure this is double
  final List<String> hotelPhotos;

  HotelDetail({
    required this.hotelID,
    required this.name,
    required this.arrivalDate,
    required this.departureDate,
    this.latitude,
    this.longitude,
    required this.address,
    required this.city,
    required this.totalPrice,
    this.currency = 'SGD',
    required this.reviewCount,
    required this.reviewScore,
    required this.hotelPhotos,
  });

  factory HotelDetail.fromJson(Map<String, dynamic> json) {
    return HotelDetail(
      // Safely convert hotelID to String
      hotelID:
          json['hotelID']?.toString() ??
          '', // Use .toString() to handle int or string
      name: json['name'] as String,
      arrivalDate: json['arrivalDate'] as String,
      departureDate: json['departureDate'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SGD',
      // Safely convert reviewCount to int
      reviewCount: (json['reviewCount'] as num)
          .toInt(), // Cast to num first, then toInt()
      // Safely convert reviewScore to double
      reviewScore: (json['reviewScore'] as num)
          .toDouble(), // Cast to num first, then toDouble()
      hotelPhotos: List<String>.from(
        json['hotelPhotos'] as List<dynamic>? ?? [],
      ),
    );
  }
}
