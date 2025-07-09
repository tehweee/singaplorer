class BookingDate {
  final String date;
  BookingDate({
    required this.date,
  });

  factory BookingDate.fromJson(Map<String, dynamic> json) {
    return BookingDate(
      date: json['start'] ?? 'No Booking',
    );
  }
}
