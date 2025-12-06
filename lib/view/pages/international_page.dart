part of 'pages.dart';

/// ======================================================================
///  PAGE 2 - INTERNATIONAL (Origin Indonesia + Destination Search)
/// ======================================================================

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  final weightController = TextEditingController(text: '');
  final destinationSearchController = TextEditingController();

  final List<String> courierOptions = ["jne", "pos", "tiki"];
  String selectedCourier = "jne";

  int? selectedProvinceOriginId;
  int? selectedCityOriginId;
  int? selectedDestinationCountryId;
  String? selectedDestinationCountryName;

  @override
  void initState() {
    super.initState();
    // Pastikan data provinsi sudah di-load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<HomeViewModel>(context, listen: false);
      if (vm.provinceList.status == Status.notStarted) {
        vm.getProvinceList();
      }
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    destinationSearchController.dispose();
    super.dispose();
  }

  void _onHitungOngkir(BuildContext context, HomeViewModel vm) {
    if (selectedCityOriginId == null ||
        selectedDestinationCountryId == null ||
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Pilih origin (provinsi & kota), destination, dan berat.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final weight = int.tryParse(weightController.text) ?? 0;
    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berat harus lebih dari 0'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    vm.checkInternationalShipmentCost(
      selectedCityOriginId!,         // origin = kota di Indonesia
      selectedDestinationCountryId!, // destination = negara luar
      weight,
      selectedCourier,
      true, // default: ambil harga termurah (boleh diabaikan di repo kalau tidak dipakai)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // ================== CARD FORM INTERNATIONAL ==================
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kurir + berat
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedCourier,
                                  items: courierOptions
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c.toUpperCase()),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedCourier = v ?? "jne";
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Berat (gr)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ================== ORIGIN (INDONESIA) ==================
                          const Text(
                            'Origin (Indonesia)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProvinceOriginDropdown(vm),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCityOriginDropdown(vm),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ================== DESTINATION (INTERNATIONAL) ==================
                          const Text(
                            'Destination (International)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: destinationSearchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Cari negara (min 3 karakter)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  vm.searchInternationalDestination(
                                      destinationSearchController.text);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          _buildInternationalDestinationList(vm),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _onHitungOngkir(context, vm),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text(
                                'Hitung Ongkir Internasional',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================== HASIL ONGKIR INTERNATIONAL ==================
                  Card(
                    color: Colors.blue[50],
                    elevation: 2,
                    child: _buildInternationalResult(vm),
                  ),
                ],
              ),
            ),

            if (vm.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  // ---------- Origin dropdown helpers ----------

  Widget _buildProvinceOriginDropdown(HomeViewModel vm) {
    if (vm.provinceList.status == Status.loading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (vm.provinceList.status == Status.error) {
      return Text(
        vm.provinceList.message ?? 'Error provinsi',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    }

    final provinces = vm.provinceList.data ?? [];
    if (provinces.isEmpty) {
      return const Text(
        'Tidak ada provinsi',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return DropdownButton<int>(
      isExpanded: true,
      value: selectedProvinceOriginId,
      hint: const Text('Provinsi'),
      items: provinces
          .map(
            (p) => DropdownMenuItem<int>(
              value: p.id,
              child: Text(p.name ?? ''),
            ),
          )
          .toList(),
      onChanged: (newId) {
        setState(() {
          selectedProvinceOriginId = newId;
          selectedCityOriginId = null;
        });
        if (newId != null) {
          vm.getCityOriginList(newId);
        }
      },
    );
  }

  Widget _buildCityOriginDropdown(HomeViewModel vm) {
    if (vm.cityOriginList.status == Status.notStarted) {
      return const Text(
        'Pilih provinsi dulu',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    if (vm.cityOriginList.status == Status.loading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (vm.cityOriginList.status == Status.error) {
      return Text(
        vm.cityOriginList.message ?? 'Error kota',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    }

    final cities = vm.cityOriginList.data ?? [];
    if (cities.isEmpty) {
      return const Text(
        'Tidak ada kota',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    final validIds = cities.map((c) => c.id).toSet();
    final validValue =
        validIds.contains(selectedCityOriginId) ? selectedCityOriginId : null;

    return DropdownButton<int>(
      isExpanded: true,
      value: validValue,
      hint: const Text('Kota'),
      items: cities
          .map(
            (c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(c.name ?? ''),
            ),
          )
          .toList(),
      onChanged: (newId) {
        setState(() {
          selectedCityOriginId = newId;
        });
      },
    );
  }

  // ---------- Destination international list ----------

  Widget _buildInternationalDestinationList(HomeViewModel vm) {
    switch (vm.internationalDestinationList.status) {
      case Status.loading:
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: LinearProgressIndicator(),
        );
      case Status.error:
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            vm.internationalDestinationList.message ??
                'Negara tidak ditemukan.',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      case Status.completed:
        final data = vm.internationalDestinationList.data ?? [];
        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Pilih kata kunci lalu tekan ikon search.\nContoh: "mal" → Malaysia, Maldives.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final isSelected =
                selectedDestinationCountryId == item.countryId;
            return InkWell(
              onTap: () {
                setState(() {
                  selectedDestinationCountryId = item.countryId;
                  selectedDestinationCountryName = item.countryName;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  item.countryName ?? '',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        );
      case Status.notStarted:
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- Hasil ongkir international ----------

  Widget _buildInternationalResult(HomeViewModel vm) {
    switch (vm.internationalCostList.status) {
      case Status.loading:
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
        );
      case Status.error:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            vm.internationalCostList.message ??
                'Terjadi kesalahan saat mengambil ongkir internasional.',
            style: const TextStyle(color: Colors.red),
          ),
        );
      case Status.completed:
        final data = vm.internationalCostList.data ?? [];
        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('Tidak ada data ongkir internasional.'),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) => CardCost(data[index]),
        );
      case Status.notStarted:
      default:
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Pilih origin & destination, lalu klik Hitung Ongkir Internasional.',
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }
}
