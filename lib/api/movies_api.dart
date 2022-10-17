import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:login/models/genres.dart';
import 'package:login/models/httpresponce.dart';
import 'package:login/models/movie_models.dart';

class moviesApi {
  final Dio _dio = Dio();

  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = 'api_key=b9c827ddc7e3741ed414d8731814ecc9';

  Future<List<Genres>> fetchGenre(String api) async {
    GenreList newGenreList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    newGenreList = GenreList.fromJson(decodeRes);
    return newGenreList.genre ?? [];
  }

  // Future<HTTPResponse<List<Mixed>>> getTrendingAll() async {
  //   final url = '$baseUrl/trending/all/week?$apiKey';
  //   final uri = Uri.parse(url);
  //   try {
  //     var response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       var body = json.decode(response.body);
  //       List<Mixed> mixedList = [];
  //       body.forEach((e) {
  //         Mixed mixed = Mixed.fromJson(e);
  //         mixedList.add(mixed);
  //       });
  //       return HTTPResponse(
  //         true,
  //         mixedList,
  //         statusCode: response.statusCode
  //       );
  //     } else {
  //       return HTTPResponse(
  //         false,
  //         null,
  //         message: 'invaild response from server',
  //         statusCode: response.statusCode);
  //     }
  //   } on SocketException {

  //   }
  // }

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

  Future<Moviedetail> fetchMovieDetails(String api) async {
    Moviedetail movieDetails;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    movieDetails = Moviedetail.fromJson(decodeRes);
    return movieDetails;
  }

  Future<List<Movie>> fetchMovies(String api) async {
    MovieList movieList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    movieList = MovieList.fromJson(decodeRes);
    return movieList.movies ?? [];
  }
  


  Future<Moviedetail> getMovieDetail(String id) async {
    try {
      final url = '$baseUrl/movie/$id?$apiKey';
      final response = await _dio.get(url);
      var movies = response.data;
      Moviedetail movie = Moviedetail.fromJson(response.data);
      return movie;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }
}
