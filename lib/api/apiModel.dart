import 'dart:io';

import 'package:http/http.dart' as http;
class ApiModel{

// Api Url response
  Future<dynamic> get(String url,) async {
    var responseJson;
    try {
      final response = await http.get(
        Uri.parse(url) ,
      );
      responseJson = response;
    } on SocketException {
      responseJson = false;
    }
    return responseJson;
  }
}