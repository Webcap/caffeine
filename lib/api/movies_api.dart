import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:caffiene/video_providers/zoro.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:caffiene/models/movie_models.dart';


class moviesApi {
  final Dio _dio = Dio();

  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = 'api_key=b9c827ddc7e3741ed414d8731814ecc9';

  Future<FlixHQStreamSources> getMovieStreamLinksAndSubsFlixHQ(
      String api) async {
    FlixHQStreamSources movieVideoSources;
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
      movieVideoSources = FlixHQStreamSources.fromJson(decodeRes);

      if (movieVideoSources.videoLinks == null ||
          movieVideoSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return movieVideoSources;
  }

  Future<List<Mixed>> getTrendingAll() async {
    print("about to get all data");
    try {
      final url = '$baseUrl/trending/all/week?$apiKey';
      final response = await _dio.get(url);
      var mixed = response.data['results'] as List;
      List<Mixed> mixedList = mixed.map((m) => Mixed.fromJson(m)).toList();
      print(mixed);
      return mixedList;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  Future<List<Movie>> getTrendingMovie() async {
    try {
      final url = '$baseUrl/trending/movie/week?$apiKey';
      final response = await _dio.get(url);
      var movies = response.data['results'] as List;
      List<Movie> movieList = movies.map((m) => Movie.fromJson(m)).toList();
      return movieList;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  Future<Moviedetail> getMovieDetail(String id) async {
    try {
      final url = '$baseUrl/movie/$id?$apiKey';
      final response = await _dio.get(url);
      Moviedetail movie = Moviedetail.fromJson(response.data);
      return movie;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  // ZORO MOVIE FUNCTIONS

  Future<List<ZoroSearchEntry>> fetchMovieTVForStreamZoro(String api) async {
    ZoroSearch zoroStream;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }

      zoroStream = ZoroSearch.fromJson(decodeRes);
      if (zoroStream.results == null || zoroStream.results!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return zoroStream.results ?? [];
  }

  Future<List<ZoroInfoEntries>> getMovieTVStreamEpisodesZoro(String api) async {
    ZoroInfo zoroInfo;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      zoroInfo = ZoroInfo.fromJson(decodeRes);

      if (zoroInfo.episodes == null || zoroInfo.episodes!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return zoroInfo.episodes ?? [];
  }
}
