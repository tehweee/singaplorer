class FlightDetail {
  final String token;
  final String departureAirport;
  final String arrivalAirport;
  final String departureCountry;
  final String arrivalCountry;
  final String departureTime;
  final String arrivalTime;
    final String price;
    final String cabinClass;


  FlightDetail({
    required this.token,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureCountry,
    required this.arrivalCountry,
    required this.departureTime,
        required this.arrivalTime,
                required this.price,
                required this.cabinClass,


  });

  factory FlightDetail.fromJson(Map<String, dynamic> json) {
    return FlightDetail(
      token: json['token'] ?? 'Unknown Airline',
      departureAirport: json['departureAirport'] ?? '',
      arrivalAirport: json['arrivalAirport'] ?? '',
      departureCountry: json['departureCountry'] ?? '',
      arrivalCountry: json['arrivalCountry'] ?? '',
      departureTime: json['departureTime'], // Safely convert int to string
            arrivalTime: json['arrivalTime'], // Safely convert int to string
                  price: json['price'].toString(), // Safely convert int to string
                              cabinClass: json['cabinClass'], // Safely convert int to string



    );
  }
}
