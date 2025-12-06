part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const <Widget>[
      DomesticPage(),
      InternationalPage(),
      ExtraPage(),
    ];
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Domestic';
      case 1:
        return 'International';
      default:
        return 'Hello';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Domestic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff),
            label: 'International',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Hello',
          ),
        ],
      ),
    );
  }
}

/// ======================================================================
///  PAGE 1 - DOMESTIC
/// ======================================================================

class DomesticPage extends StatefulWidget {
  const DomesticPage({super.key});

  @override
  State<DomesticPage> createState() => _DomesticPageState();
}

class _DomesticPageState extends State<DomesticPage> {
  late HomeViewModel homeViewModel;

  final weightController = TextEditingController();

  final List<String> courierOptions = ["jne", "pos", "tiki", "lion", "sicepat"];
  String selectedCourier = "jne";

  int? selectedProvinceOriginId;
  int? selectedCityOriginId;
  int? selectedProvinceDestinationId;
  int? selectedCityDestinationId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      if (homeViewModel.provinceList.status == Status.notStarted) {
        homeViewModel.getProvinceList();
      }
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // ---------------- CARD FORM DOMESTIC ----------------
              Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 24),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Origin",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Consumer<HomeViewModel>(
                              builder: (context, vm, _) {
                                if (vm.provinceList.status ==
                                    Status.loading) {
                                  return const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.black),
                                    ),
                                  );
                                }
                                if (vm.provinceList.status == Status.error) {
                                  return Text(
                                    vm.provinceList.message ?? 'Error',
                                    style:
                                        const TextStyle(color: Colors.red),
                                  );
                                }

                                final provinces =
                                    vm.provinceList.data ?? [];
                                if (provinces.isEmpty) {
                                  return const Text('Tidak ada provinsi');
                                }

                                return DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedProvinceOriginId,
                                  hint: const Text('Pilih provinsi'),
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
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer<HomeViewModel>(
                              builder: (context, vm, _) {
                                if (vm.cityOriginList.status ==
                                    Status.notStarted) {
                                  return const Text(
                                    'Pilih provinsi dulu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                                if (vm.cityOriginList.status ==
                                    Status.loading) {
                                  return const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.black),
                                    ),
                                  );
                                }
                                if (vm.cityOriginList.status ==
                                    Status.error) {
                                  return Text(
                                    vm.cityOriginList.message ?? 'Error',
                                    style:
                                        const TextStyle(color: Colors.red),
                                  );
                                }

                                final cities =
                                    vm.cityOriginList.data ?? [];
                                if (cities.isEmpty) {
                                  return const Text(
                                    'Tidak ada kota',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }

                                final validIds =
                                    cities.map((c) => c.id).toSet();
                                final validValue =
                                    validIds.contains(selectedCityOriginId)
                                        ? selectedCityOriginId
                                        : null;

                                return DropdownButton<int>(
                                  isExpanded: true,
                                  value: validValue,
                                  hint: const Text('Pilih kota'),
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
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Destination",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Consumer<HomeViewModel>(
                              builder: (context, vm, _) {
                                if (vm.provinceList.status ==
                                    Status.loading) {
                                  return const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.black),
                                    ),
                                  );
                                }
                                if (vm.provinceList.status == Status.error) {
                                  return Text(
                                    vm.provinceList.message ?? 'Error',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                final provinces =
                                    vm.provinceList.data ?? [];
                                if (provinces.isEmpty) {
                                  return const Text('Tidak ada provinsi');
                                }

                                return DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedProvinceDestinationId,
                                  hint: const Text('Pilih provinsi'),
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
                                      selectedProvinceDestinationId = newId;
                                      selectedCityDestinationId = null;
                                    });
                                    if (newId != null) {
                                      vm.getCityDestinationList(newId);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer<HomeViewModel>(
                              builder: (context, vm, _) {
                                if (vm.cityDestinationList.status ==
                                    Status.notStarted) {
                                  return const Text(
                                    'Pilih provinsi dulu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                                if (vm.cityDestinationList.status ==
                                    Status.loading) {
                                  return const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.black),
                                    ),
                                  );
                                }
                                if (vm.cityDestinationList.status ==
                                    Status.error) {
                                  return Text(
                                    vm.cityDestinationList.message ?? 'Error',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                final cities =
                                    vm.cityDestinationList.data ?? [];
                                if (cities.isEmpty) {
                                  return const Text(
                                    'Tidak ada kota',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }

                                final validIds =
                                    cities.map((c) => c.id).toSet();
                                final validValue =
                                    validIds.contains(
                                            selectedCityDestinationId)
                                        ? selectedCityDestinationId
                                        : null;

                                return DropdownButton<int>(
                                  isExpanded: true,
                                  value: validValue,
                                  hint: const Text('Pilih kota'),
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
                                      selectedCityDestinationId = newId;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedCityOriginId != null &&
                                selectedCityDestinationId != null &&
                                weightController.text.isNotEmpty &&
                                selectedCourier.isNotEmpty) {
                              final weight =
                                  int.tryParse(weightController.text) ?? 0;
                              if (weight <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Berat harus lebih dari 0'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              homeViewModel.checkShipmentCost(
                                selectedCityOriginId!.toString(),
                                "city",
                                selectedCityDestinationId!.toString(),
                                "city",
                                weight,
                                selectedCourier,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lengkapi semua field!'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text(
                            "Hitung Ongkir",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- CARD HASIL ONGKIR DOMESTIC ----------------
              Card(
                color: Colors.blue[50],
                elevation: 2,
                child: Consumer<HomeViewModel>(
                  builder: (context, vm, _) {
                    switch (vm.costList.status) {
                      case Status.loading:
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      case Status.error:
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              vm.costList.message ?? 'Error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      case Status.completed:
                        if (vm.costList.data == null ||
                            vm.costList.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text("Tidak ada data ongkir."),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vm.costList.data?.length ?? 0,
                          itemBuilder: (context, index) => CardCost(
                            vm.costList.data!.elementAt(index),
                          ),
                        );
                      default:
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              "Pilih kota dan klik Hitung Ongkir terlebih dulu.",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
