//for refill reminder
class RefillModel {
  String medicineName;
  String medicineType;
  String time;
  String uid;
  String date;
  int notifyId;
  RefillModel({
    required this.medicineName,
    required this.medicineType,
    required this.time,
    required this.uid,
    required this.date, required this.notifyId,
  });
  // from map- which means getting the data from the server
  factory  RefillModel.fromMap(Map<String, dynamic> map) {
    return  RefillModel(
      medicineName: map['medicineName'] ?? '',
      medicineType: map['medicineType'] ?? '',
      time: map['startTime'] ?? '',
      uid: map['uid'] ?? '',
      date: map['dateTime'] ?? '',
      notifyId: map['notifyId'] ?? '',
    );
  }
  // to map - sending the data to our server
  Map<String, dynamic> toMap() {
    return {
      "medicineName": medicineName,
      "medicineType": medicineType,
      "time":time,
      "uid": uid,
      "date":date,
      "notifyId":notifyId,
    };
  }
}
