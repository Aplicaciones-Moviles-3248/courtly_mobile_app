import '../models/court_model.dart';

class CourtMockDataSource {
  Future<List<CourtModel>> getCourts() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      CourtModel(
        id: '1',
        name: 'Arena Norte',
        district: 'San Isidro',
        sport: 'Fútbol 7',
        description: 'Cancha de fútbol 7 con iluminación LED, vestidores y estacionamiento.',
        address: 'Av. Del Parque 180, San Isidro',
        pricePerHour: 120,
        availableSchedules: 3,
        imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018',
        isAvailable: true,
      ),
      CourtModel(
        id: '2',
        name: 'Green Point Club',
        district: 'Miraflores',
        sport: 'Padel',
        description: 'Cancha moderna de padel con zona de espera y servicios complementarios.',
        address: 'Av. La Paz 250, Miraflores',
        pricePerHour: 95,
        availableSchedules: 2,
        imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6',
        isAvailable: true,
      ),
    ];
  }

  Future<CourtModel> getCourtById(String courtId) async {
    final courts = await getCourts();

    return courts.firstWhere(
          (court) => court.id == courtId,
      orElse: () => courts.first,
    );
  }
}