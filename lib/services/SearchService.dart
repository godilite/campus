import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

class SearchService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = new Dio();
  Future search(String text) async {
    final SharedPreferences prefs = await _prefs;
    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.post("http://10.0.2.2:8000/api/v1/search", data: {
        'search': text ?? '',
      });
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }

    return response;
  }

  Future<List> searchPosts(words) async {}
}
