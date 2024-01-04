import 'dart:async';
import 'dart:io';

import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:caffiene/utils/config.dart';

class tvApi {
  Future<List<TV>> fetchPersonTV(String api) async {
    PersonTVList personTVList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    personTVList = PersonTVList.fromJson(decodeRes);
    return personTVList.tv ?? [];
  }

  Future<List<TV>> fetchTV(String api) async {
    TVList tvList;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      tvList = TVList.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return tvList.tvSeries ?? [];
  }

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

  Future<FlixHQTVInfo> getTVStreamEpisodesFlixHQ(String api) async {
    FlixHQTVInfo tvInfo;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      tvInfo = FlixHQTVInfo.fromJson(decodeRes);

      if (tvInfo.episodes == null || tvInfo.episodes!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return tvInfo;
  }

  Future<List<FlixHQTVSearchEntry>> fetchTVForStreamFlixHQ(String api) async {
    FlixHQTVSearch tvStream;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      tvStream = FlixHQTVSearch.fromJson(decodeRes);

      if (tvStream.results == null || tvStream.results!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return tvStream.results ?? [];
  }

  Future<TVDetails> fetchTVDetails(String api) async {
    TVDetails tvDetails;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    tvDetails = TVDetails.fromJson(decodeRes);
    return tvDetails;
  }
}
