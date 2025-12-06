import 'package:depd_mvvm_2025/data/network/network_api_service.dart';
import 'package:depd_mvvm_2025/model/model.dart';

// Repository untuk menangani logika bisnis terkait data ongkir
class HomeRepository {
  // NetworkApiServices hanya perlu 1 instance sehingga tidak perlu ganti service selama aplikasi berjalan
  final _apiServices = NetworkApiServices();


  // Mengambil daftar provinsi dari API
  Future<List<Province>> fetchProvinceList() async {
    final response = await _apiServices.getApiResponse('destination/province');

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Province.fromJson(e)).toList();
  }

  // Mengambil daftar kota berdasarkan ID provinsi
  Future<List<City>> fetchCityList(var provId) async {
    final response =
        await _apiServices.getApiResponse('destination/city/$provId');

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => City.fromJson(e)).toList();
  }

  // Menghitung biaya pengiriman DOMESTIK
  Future<List<Costs>> checkShipmentCost(
    String origin,
    String originType,
    String destination,
    String destinationType,
    int weight,
    String courier,
  ) async {
    final response = await _apiServices.postApiResponse(
      'calculate/domestic-cost',
      {
        "origin": origin,
        "originType": originType,
        "destination": destination,
        "destinationType": destinationType,
        "weight": weight.toString(),
        "courier": courier,
      },
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Costs.fromJson(e)).toList();
  }


  /// Search International Destination
  /// GET https://rajaongkir.komerce.id/api/v1/destination/international-destination
  /// ?search={country_name}&limit=99&offset=0
  Future<List<InternationalDestination>> searchInternationalDestination(
      String keyword) async {
    final cleaned = keyword.trim();
    if (cleaned.isEmpty) return [];

    final endpoint =
        'destination/international-destination?search=$cleaned&limit=20&offset=0';

    final response = await _apiServices.getApiResponse(endpoint);

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data
        .map((e) => InternationalDestination.fromJson(
            e as Map<String, dynamic>))
        .toList();
  }


  Future<List<Costs>> checkInternationalShipmentCost(
    int originId,
    int destinationId,
    int weight,
    String courier,
  ) async {
    final response = await _apiServices.postApiResponse(
      'calculate/international-cost',
      {
        'origin': originId.toString(),
        'destination': destinationId.toString(),
        'weight': weight.toString(),
        'courier': courier,
      },
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Costs.fromJson(e)).toList();
  }
}
