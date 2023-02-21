//will get the info fetched from the api here
class MedInfoModel {
  List<dynamic> active_ingredient;
  List<dynamic> purpose;
  List<dynamic> indications_and_usage;
  List<dynamic> warnings;
  List<dynamic> dosage_and_administration;
  List<dynamic> storage_and_handling;

  MedInfoModel({
    required this.active_ingredient,
    required this.purpose,
    required this.indications_and_usage,
    required this.warnings,
    required this.dosage_and_administration,
    required this.storage_and_handling,
  });
  // from map- which means getting the data from the server
  factory MedInfoModel.fromMap(Map<String,dynamic> map) {
    return MedInfoModel(
      active_ingredient: map['active_ingredient'] ?? '',
      purpose: map['purpose'] ?? '',
      indications_and_usage: map['indications_and_usage'] ?? '',
      warnings: map['warnings'] ?? '',
      dosage_and_administration: map['dosage_and_administration'] ?? '',
      storage_and_handling: map['storage_and_handling'] ?? '',
    );
   }
}
