import 'package:flutter/foundation.dart';
import 'package:depd_mvvm_2025/data/response/api_response.dart';
import 'package:depd_mvvm_2025/data/response/status.dart';
import 'package:depd_mvvm_2025/model/model.dart';
import 'package:depd_mvvm_2025/repository/home_repository.dart';

// ViewModel untuk mengelola data dan state Home (provinsi, kota, ongkir)
class HomeViewModel with ChangeNotifier {
  // Repository untuk akses API
  final _homeRepo = HomeRepository();

  ApiResponse<List<Province>> provinceList = ApiResponse.notStarted();
  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  // Ambil daftar provinsi
  Future getProvinceList() async {
    if (provinceList.status == Status.completed) return;
    setProvinceList(ApiResponse.loading());
    _homeRepo
        .fetchProvinceList()
        .then((value) {
          setProvinceList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setProvinceList(ApiResponse.error(error.toString()));
        });
  }

  // Cache kota per id provinsi agar tidak panggil API berulang
  final Map<int, List<City>> _cityCache = {};

  // State daftar kota asal
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();
  setCityOriginList(ApiResponse<List<City>> response) {
    cityOriginList = response;
    notifyListeners();
  }

  // Ambil kota asal
  Future getCityOriginList(int provId) async {
    if (_cityCache.containsKey(provId)) {
      setCityOriginList(ApiResponse.completed(_cityCache[provId]!));
      return;
    }
    setCityOriginList(ApiResponse.loading());
    _homeRepo
        .fetchCityList(provId)
        .then((value) {
          _cityCache[provId] = value;
          setCityOriginList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setCityOriginList(ApiResponse.error(error.toString()));
        });
  }

  // State daftar kota tujuan
  ApiResponse<List<City>> cityDestinationList = ApiResponse.notStarted();
  setCityDestinationList(ApiResponse<List<City>> response) {
    cityDestinationList = response;
    notifyListeners();
  }

  // Ambil kota tujuan
  Future getCityDestinationList(int provId) async {
    if (_cityCache.containsKey(provId)) {
      setCityDestinationList(ApiResponse.completed(_cityCache[provId]!));
      return;
    }
    setCityDestinationList(ApiResponse.loading());
    _homeRepo
        .fetchCityList(provId)
        .then((value) {
          _cityCache[provId] = value;
          setCityDestinationList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setCityDestinationList(ApiResponse.error(error.toString()));
        });
  }


  ApiResponse<List<Costs>> costList = ApiResponse.notStarted();
  setCostList(ApiResponse<List<Costs>> response) {
    costList = response;
    notifyListeners();
  }

  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future checkShipmentCost(
    String origin,
    String originType,
    String destination,
    String destinationType,
    int weight,
    String courier,
  ) async {
    setLoading(true);
    setCostList(ApiResponse.loading());

    _homeRepo
        .checkShipmentCost(
          origin,
          originType,
          destination,
          destinationType,
          weight,
          courier,
        )
        .then((value) {
          setCostList(ApiResponse.completed(value));
          setLoading(false);
        })
        .onError((error, _) {
          setCostList(ApiResponse.error(error.toString()));
          setLoading(false);
        });
  }

  // hasil search negara untuk origin
  ApiResponse<List<InternationalDestination>> internationalOriginList =
      ApiResponse.notStarted();
  void setInternationalOriginList(
      ApiResponse<List<InternationalDestination>> response) {
    internationalOriginList = response;
    notifyListeners();
  }

  // hasil search negara untuk destination
  ApiResponse<List<InternationalDestination>> internationalDestinationList =
      ApiResponse.notStarted();
  void setInternationalDestinationList(
      ApiResponse<List<InternationalDestination>> response) {
    internationalDestinationList = response;
    notifyListeners();
  }

  // hasil biaya ongkir internasional
  ApiResponse<List<Costs>> internationalCostList = ApiResponse.notStarted();
  void setInternationalCostList(ApiResponse<List<Costs>> response) {
    internationalCostList = response;
    notifyListeners();
  }

  // search origin country
  Future searchInternationalOrigin(String keyword) async {
    if (keyword.trim().isEmpty) {
      setInternationalOriginList(ApiResponse.completed([]));
      return;
    }
    setInternationalOriginList(ApiResponse.loading());
    _homeRepo
        .searchInternationalDestination(keyword)
        .then((value) {
          setInternationalOriginList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setInternationalOriginList(ApiResponse.error(error.toString()));
        });
  }

  // search destination country
  Future searchInternationalDestination(String keyword) async {
    if (keyword.trim().isEmpty) {
      setInternationalDestinationList(ApiResponse.completed([]));
      return;
    }
    setInternationalDestinationList(ApiResponse.loading());
    _homeRepo
        .searchInternationalDestination(keyword)
        .then((value) {
          setInternationalDestinationList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setInternationalDestinationList(ApiResponse.error(error.toString()));
        });
  }

  // hitung ongkir internasional
  Future checkInternationalShipmentCost(
    int originId,
    int destinationId,
    int weight,
    String courier,
    bool lowestPrice,
  ) async {
    setLoading(true);
    setInternationalCostList(ApiResponse.loading());

    _homeRepo
        .checkInternationalShipmentCost(
          originId,
          destinationId,
          weight,
          courier,
        )
        .then((value) {
          setInternationalCostList(ApiResponse.completed(value));
          setLoading(false);
        })
        .onError((error, _) {
          setInternationalCostList(ApiResponse.error(error.toString()));
          setLoading(false);
        });
  }
}
