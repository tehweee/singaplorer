class Hotel {
  final String name;
  final int starRating;
  final double reviewScore;
  final String reviewText;
  final int reviewCount;
  final double priceGross;
  final String priceCurrency;
  final String checkInDate;
  final String checkInFrom;
  final String checkInUntil;
  final String checkOutDate;
  final String checkOutFrom;
  final String checkOutUntil;
  final List imageUrls;
  final String accessibilityLabel;
  final String hotelID;


  Hotel({
  required this.name,
  required this.starRating,
  required this.reviewScore,
  required this.reviewText,
  required this.reviewCount,
  required this.priceGross,
  required this.priceCurrency,
  required this.checkInDate,
  required this.checkInFrom,
  required this.checkInUntil,
  required this.checkOutDate,
  required this.checkOutFrom,
  required this.checkOutUntil,
  required this.imageUrls,
  required this.accessibilityLabel,
  required this.hotelID
  });

factory Hotel.fromJson(Map<String, dynamic> json) {
  return Hotel(
    name: json['name'] ?? '',
    starRating: json['starRating'] ?? 0,
    reviewScore: json['reviewScore'] is num
        ? (json['reviewScore'] as num).toDouble()
        : 0.0,
    reviewText: json['reviewText'] ?? '',
    reviewCount: json['reviewCount'] ?? 0,
    priceGross: json['priceGross'] is num
        ? (json['priceGross'] as num).toDouble()
        : 0.0,
    priceCurrency: json['priceCurrency'] ?? '',
    checkInDate: json['checkInDate'] ?? '',
    checkInFrom: json['checkInFrom'] ?? '',
    checkInUntil: json['checkInUntil'] ?? '',
    checkOutDate: json['checkOutDate'] ?? '',
    checkOutFrom: json['checkOutFrom'] ?? '',
    checkOutUntil: json['checkOutUntil'] ?? '',
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    accessibilityLabel: json['accessibilityLabel'] ?? '',
    hotelID: json['hotelID'].toString(),
  );
}
}
