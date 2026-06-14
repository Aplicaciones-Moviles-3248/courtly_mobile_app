class Court {
  final String id;
  final String name;
  final String district;
  final String sport;
  final String description;
  final String address;
  final double pricePerHour;
  final int availableSchedules;
  final String imageUrl;
  final bool isAvailable;

  const Court({
    required this.id,
    required this.name,
    required this.district,
    required this.sport,
    required this.description,
    required this.address,
    required this.pricePerHour,
    required this.availableSchedules,
    required this.imageUrl,
    required this.isAvailable,
  });
}