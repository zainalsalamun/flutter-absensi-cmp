import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/request/checkinout_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/reimbursement_response_model.dart';
import 'package:http/http.dart' as http;

class ReimbursementRemoteDatasource {
  Future<Either<String, List<Reimbursement>>> getReimbursements() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/reimbursements');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      final reimbursementResponse =
          ReimbursementResponseModel.fromJson(response.body);
      return Right(reimbursementResponse.data ?? []);
    } else {
      try {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to get reimbursements');
      } catch (e) {
        return Left('Failed to get reimbursements: ${response.statusCode}');
      }
    }
  }

  Future<Either<String, ReimbursementResponseModel>> addReimbursement(
      CheckInOutRequestModel data) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/reimbursements');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
      body: data.toJson(),
    );

    if (response.statusCode == 201) {
      return Right(
          ReimbursementResponseModel.fromJson(jsonDecode(response.body)));
    } else {
      try {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to add reimbursement');
      } catch (e) {
        return Left('Failed to add reimbursement: ${response.statusCode}');
      }
    }
  }
}
