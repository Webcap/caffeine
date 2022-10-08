import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login/models/models.dart';
import 'package:login/utils/movies_api.dart';

class MovieProvider extends ChangeNotifier {
  final moviesApi _movies = moviesApi();
  bool isLoading = false;
  List<Mixed> _mixed = [];
  List<Mixed> get mixed => _mixed;

  Future<void> fetchTrendingMovieData() async {
    isLoading = true;
    notifyListeners();

    final response = await _movies.getTrendingAll();
    
    _mixed = response;
    isLoading = false;
    notifyListeners();
  }
}
