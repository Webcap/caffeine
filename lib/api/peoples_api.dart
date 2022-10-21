import 'dart:convert';

import 'package:login/models/person.dart';
import 'package:http/http.dart' as http;

class peoplesApi {

  Future<List<Person>> fetchPerson(String api) async {
    PersonList credits;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    credits = PersonList.fromJson(decodeRes);
    return credits.person ?? [];
  }

}