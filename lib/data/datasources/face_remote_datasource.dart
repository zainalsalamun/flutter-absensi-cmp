import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import 'auth_local_datasource.dart';

class FaceRemoteDatasource {
  Future<Either<String, Map<String, dynamic>>> enrollFace(String imagePath) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/face-enrollment');

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authData?.token}',
    });

    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Right(jsonDecode(response.body));
    } else {
      try {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to enroll face');
      } catch (e) {
        return Left('Failed to enroll face: ${response.statusCode}');
      }
    }
  }

  Future<Either<String, Map<String, dynamic>>> checkFaceStatus() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/face-status');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(jsonDecode(response.body));
    } else {
      try {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to check face status');
      } catch (e) {
        return Left('Failed to check face status: ${response.statusCode}');
      }
    }
  }
}
