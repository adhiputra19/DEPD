part of 'model.dart';

class Costs extends Equatable {
  final String? name;
  final String? code;
  final String? service;
  final String? description;
  final num? cost;      // <- num (bisa int / double)
  final String? etd;

  const Costs({
    this.name,
    this.code,
    this.service,
    this.description,
    this.cost,
    this.etd,
  });

  factory Costs.fromJson(Map<String, dynamic> json) {
    // cost bisa int / double / string -> kita amankan
    final rawCost = json['cost'];
    num? parsedCost;
    if (rawCost is num) {
      parsedCost = rawCost;
    } else if (rawCost != null) {
      parsedCost = num.tryParse(rawCost.toString());
    }

    return Costs(
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      service: json['service']?.toString(),
      description: json['description']?.toString(),
      cost: parsedCost,
      etd: json['etd']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'service': service,
        'description': description,
        'cost': cost,
        'etd': etd,
      };

  @override
  List<Object?> get props => [name, code, service, description, cost, etd];
}
