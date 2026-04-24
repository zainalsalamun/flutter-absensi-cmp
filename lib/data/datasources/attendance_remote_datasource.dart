import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/request/checkinout_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/checkinout_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/company_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AttendanceRemoteDatasource {
  Future<Either<String, CompanyResponseModel>> getCompanyProfile() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/company');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('[Company] Response body: ${response.body}');
      final model = CompanyResponseModel.fromJson(response.body);
      debugPrint('[Company] attendanceType: ${model.company?.attendanceType}');
      return Right(model);
    } else {
      return const Left('Failed to get company profile');
    }
  }

  Future<Either<String, (bool, bool)>> isCheckedin() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/is-checkin');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Right((
        responseData['checkedin'] as bool,
        responseData['checkedout'] as bool
      ));
    } else {
      return const Left('Failed to get checkedin status');
    }
  }

  Future<Either<String, CheckInOutResponseModel>> checkin(
      CheckInOutRequestModel data) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/checkin');
    
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authData?.token}',
    });

    if (data.latitude != null) {
      request.fields['latitude'] = data.latitude!;
    }
    if (data.longitude != null) {
      request.fields['longitude'] = data.longitude!;
    }
    
    if (data.photo != null) {
      debugPrint('Uploading photo from path: ${data.photo}');
      final file = await http.MultipartFile.fromPath(
        'photo',
        data.photo!,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
      debugPrint('File added to request: ${file.filename}, size: ${file.length} bytes');
    }

    debugPrint('Request Fields: ${request.fields}');
    debugPrint('Request Headers: ${request.headers}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Response Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return Right(CheckInOutResponseModel.fromJson(response.body));
    } else {
      try {
        final error = jsonDecode(response.body);
        debugPrint('Error from server: ${error['message']}');
        return Left(error['message'] ?? 'Failed to checkin');
      } catch (e) {
        debugPrint('Error decoding error response: $e');
        return Left('Failed to checkin: ${response.statusCode}');
      }
    }
  }

  Future<Either<String, CheckInOutResponseModel>> checkout(
      CheckInOutRequestModel data) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/checkout');
    
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authData?.token}',
    });

    if (data.latitude != null) {
      request.fields['latitude'] = data.latitude!;
    }
    if (data.longitude != null) {
      request.fields['longitude'] = data.longitude!;
    }
    
    if (data.photo != null) {
      debugPrint('Uploading photo from path: ${data.photo}');
      final file = await http.MultipartFile.fromPath(
        'photo',
        data.photo!,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
      debugPrint('File added to request: ${file.filename}, size: ${file.length} bytes');
    }

    debugPrint('Request Fields: ${request.fields}');
    debugPrint('Request Headers: ${request.headers}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Response Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return Right(CheckInOutResponseModel.fromJson(response.body));
    } else {
      try {
        final error = jsonDecode(response.body);
        debugPrint('Error from server: ${error['message']}');
        return Left(error['message'] ?? 'Failed to checkout');
      } catch (e) {
        debugPrint('Error decoding error response: $e');
        return Left('Failed to checkout: ${response.statusCode}');
      }
    }
  }

  Future<Either<String, AttendanceResponseModel>> getAttendance(
      String date) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url =
        Uri.parse('${Variables.baseUrl}/api/api-attendances?date=$date');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(AttendanceResponseModel.fromJson(response.body));
    } else {
      return const Left('Failed to get attendance');
    }
  }
}
