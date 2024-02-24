import 'dart:async';
import 'dart:io';

import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class tvApi {


  Future<FlixHQStreamSources> getTVStreamLinksAndSubsFlixHQ(String api) async {
    FlixHQStreamSources tvVideoSources;
    int tries = 3;
    dynamic decodeRes;
    try {
      dynamic res;
      while (tries > 0) {
        res = await retryOptionsStream.retry(
          (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        decodeRes = jsonDecode(res.body);
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      tvVideoSources = FlixHQStreamSources.fromJson(decodeRes);

      if (tvVideoSources.videoLinks == null ||
          tvVideoSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return tvVideoSources;
  }

}
