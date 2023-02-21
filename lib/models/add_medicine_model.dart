class MedicineModel {
  String medicineName;
  int dosage;
  String medicineType;
  int interval;
  String startTime;
  String uid;
  String dateTime;
  int notifyId;
  MedicineModel({
    required this.medicineName,
    required this.dosage,
    required this.medicineType,
    required this.startTime,
    required this.interval,
    required this.uid,
    required this.dateTime, required this.notifyId,
  });
  // from map- which means getting the data from the server
  factory  MedicineModel.fromMap(Map<String, dynamic> map) {
    return  MedicineModel(
      medicineName: map['medicineName'] ?? '',
      dosage: map['dosage'] ?? '',
      medicineType: map['medicineType'] ?? '',
      startTime: map['startTime'] ?? '',
      interval: map['interval'] ?? '',
      uid: map['uid'] ?? '',
      dateTime: map['dateTime'] ?? '',
      notifyId: map['notifyId'] ?? '',
    );
  }
  // to map - sending the data to our server
  Map<String, dynamic> toMap() {
    return {
      "medicineName": medicineName,
      "dosage": dosage,
      "medicineType": medicineType,
      "startTime": startTime,
      "interval": interval,
      "uid": uid,
      "dateTime":dateTime,
      "notifyId":notifyId,
    };
  }
}
