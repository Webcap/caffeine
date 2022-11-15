import 'package:login/models/poster.dart';

class GenreList {
  List<Genres>? genre;

  GenreList({
    this.genre,
  });

  GenreList.fromJson(Map<String, dynamic> json) {
    if (json['genres'] != null) {
      genre = [];
      json['genres'].forEach((v) {
        genre?.add(Genres.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (genre != null) {
      data['genres'] = genre?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Genres {
  String? genreName;
  int? genreID;
  Genres({this.genreName, this.genreID});
  Genres.fromJson(Map<String, dynamic> json) {
    genreName = json['name'];
    genreID = json['id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = genreName;
    data['id'] = genreID;
    return data;
  }
}

class Genre {
  int id;
  String title;
  List<Poster>? posters;

  Genre({required this.id, required this.title, this.posters});

  factory Genre.fromJson(Map<String, dynamic> parsedJson) {
    List<Poster> posters = [];
    if (parsedJson['posters'] != null)
      for (Map<String, dynamic> i in parsedJson['posters']) {
        Poster poster = Poster.fromJson(i);
        posters.add(poster);
      }

    return Genre(
        id: parsedJson['id'], title: parsedJson['title'], posters: posters);
  }
}
