part of 'model.dart';

class InternationalDestination extends Equatable {
  final int? countryId;
  final String? countryName;

  const InternationalDestination({
    this.countryId,
    this.countryName,
  });

  factory InternationalDestination.fromJson(Map<String, dynamic> json) {
    return InternationalDestination(
      countryId: int.tryParse(json['country_id'].toString()),
      countryName: json['country_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'country_id': countryId,
        'country_name': countryName,
      };

  @override
  List<Object?> get props => [countryId, countryName];
}
