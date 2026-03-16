import 'dart:convert';

class CheckInOutRequestModel {
  final String? latitude;
  final String? longitude;
  final String? photo;

  CheckInOutRequestModel({this.latitude, this.longitude, this.photo});

  factory CheckInOutRequestModel.fromJson(String str) =>
      CheckInOutRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CheckInOutRequestModel.fromMap(Map<String, dynamic> json) =>
      CheckInOutRequestModel(
        latitude: json["latitude"],
        longitude: json["longitude"],
        photo: json["photo"],
      );

  Map<String, dynamic> toMap() => {
    "latitude": latitude,
    "longitude": longitude,
    "photo": photo,
  };
}
