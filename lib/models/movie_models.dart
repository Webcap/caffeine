import 'package:login/models/genres.dart';

class PersonMoviesList {
  List<Movie>? movies;
  PersonMoviesList({this.movies});
  PersonMoviesList.fromJson(Map<String, dynamic> json) {
    if (json['cast'] != null) {
      movies = [];
      json['cast'].forEach((v) {
        movies!.add(Movie.fromJson(v));
      });
    }
    if (json['crew'] != null) {
      if (json['cast'] == null) {
        movies = [];
      }
      json['crew'].forEach((v) {
        movies!.add(Movie.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (movies != null) {
      data['cast'] = movies!.map((v) => v.toJson()).toList();
    }
    if (movies != null) {
      data['crew'] = movies!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ExternalLinks {
  String? facebookUsername;
  String? instagramUsername;
  String? twitterUsername;
  String? imdbId;

  ExternalLinks({
    this.facebookUsername,
    this.imdbId,
    this.instagramUsername,
    this.twitterUsername,
  });
  ExternalLinks.fromJson(Map<String, dynamic> json) {
    facebookUsername = json['facebook_id'];
    instagramUsername = json['instagram_id'];
    imdbId = json['imdb_id'];
    twitterUsername = json['twitter_id'];
  }
}

class MovieList {
  int? page;
  int? totalMovies;
  int? totalPages;
  List<Movie>? movies;

  MovieList({this.page, this.totalMovies, this.totalPages, this.movies});

  MovieList.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    totalMovies = json['total_results'];
    totalPages = json['total_pages'];
    if (json['results'] != null) {
      movies = [];
      json['results'].forEach((v) {
        movies!.add(Movie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['total_results'] = totalMovies;
    data['total_pages'] = totalPages;
    if (movies != null) {
      data['results'] = movies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Mixed {
  bool? adult;
  String? backdropPath;
  int? id;
  String? title;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  String? posterPath;
  String? mediaType;
  double? voteAverage;

  Mixed(
      {this.adult,
      this.backdropPath,
      this.id,
      this.title,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.posterPath,
      this.mediaType,
      this.voteAverage});

  Mixed.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    backdropPath = json['backdropPath'];
    id = json['id'];
    title = json['title'];
    if (title == null) {
      title = json['name'];
    }
    originalLanguage = json['originalLanguage'];
    originalTitle = json['originalTitle'];
    if (title == null) {
      originalTitle = json['originalname'];
    }
    overview = json['overview'];
    posterPath = json['poster_path'];
    mediaType = json['media_type'];
    voteAverage = json['vote_average'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['adult'] = adult;
    data['backdropPath'] = this.backdropPath;
    data['id'] = this.id;
    data['title'] = this.title;
    if (title == null) {
      data['name'] = this.title;
    }
    data['originalLanguage'] = this.originalLanguage;
    data['originalTitle'] = this.originalTitle;
    if (title == null) {
      data['original_name'] = this.originalTitle;
    }
    data['overview'] = this.overview;
    data['poster_path'] = this.posterPath;
    data['media_type'] = this.mediaType;
    data['vote_average'] = this.voteAverage;
    return data;
  }
}

class Movie {
  bool? adult;
  int? voteCount;
  String? backdropPath;
  int? id;
  String? title;
  num? voteAverage;
  
  String? originalLanguage;
  String? originalTitle;
  String? releaseDate;
  String? posterPath;
  String? overview;

  Movie(
      {this.adult,
      this.backdropPath,
      this.id,
      this.title,
      this.voteAverage,
      this.voteCount,
      this.overview,
      this.releaseDate,
      this.originalLanguage,
      this.originalTitle,
      this.posterPath});

  Movie.fromJson(Map<String, dynamic> json) {
    voteCount = json['vote_count'];
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    id = json['id'];
    title = json['title'];
    voteAverage = json['vote_average'];
    originalLanguage = json['original_language'];
    releaseDate = json['release_date'];
    overview = json['overview'];
    originalTitle = json['original_title'];
    posterPath = json['poster_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['adult'] = this.adult;
    data['backdrop_path'] = this.backdropPath;
    data['id'] = this.id;
    data['vote_count'] = this.voteCount;
    data['title'] = this.title;
    data['vote_average'] = voteAverage;
    data['original_language'] = this.originalLanguage;
    data['original_title'] = this.originalTitle;
    data['poster_path'] = this.posterPath;
    data['overview'] = this.overview;
    data['release_date'] = this.releaseDate;
    return data;
  }
}

class SpokenLanguages {
  String? englishName;
  SpokenLanguages({this.englishName});
  SpokenLanguages.fromJson(Map<String, dynamic> json) {
    englishName = json['english_name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['english_name'] = englishName;
    return data;
  }
}

class ProductionCompanies {
  String? name;
  ProductionCompanies({this.name});
  ProductionCompanies.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    return data;
  }
}

class ProductionCountries {
  String? name;
  ProductionCountries({this.name});
  ProductionCountries.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    return data;
  }
}

class Moviedetail {
  bool? adult;
  String? backdropPath;
  int? budget;
  List<Genres>? genres;
  String? homepage;
  int? id;
  String? imdbId;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  double? popularity;
  String? posterPath;
  String? releaseDate;
  int? revenue;
  int? runtime;
  String? status;
  String? tagline;
  String? title;
  double? voteAverage;
  int? voteCount;

  
  List<ProductionCompanies>? productionCompanies;
  List<ProductionCountries>? productionCountries;
  List<SpokenLanguages>? spokenLanguages;

  Moviedetail(
      {this.adult,
      this.backdropPath,
      this.budget,
      this.genres,
      this.homepage,
      this.id,
      this.imdbId,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.spokenLanguages,
      this.popularity,
      this.posterPath,
      this.releaseDate,
      this.revenue,
      this.runtime,
      this.status,
      this.productionCompanies,
      this.productionCountries,
      this.tagline,
      this.title,
      this.voteAverage,
      this.voteCount});

  Moviedetail.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    budget = json['budget'];
    if (json['genres'] != null) {
      genres = <Genres>[];
      json['genres'].forEach((v) {
        genres!.add(new Genres.fromJson(v));
      });
    }
    if (json['spoken_languages'] != null) {
      spokenLanguages = [];
      json['spoken_languages'].forEach((v) {
        spokenLanguages?.add(SpokenLanguages.fromJson(v));
      });
    }
    if (json['production_companies'] != null) {
      productionCompanies = [];
      json['production_companies'].forEach((v) {
        productionCompanies?.add(ProductionCompanies.fromJson(v));
      });
    }
    if (json['production_countries'] != null) {
      productionCountries = [];
      json['production_countries'].forEach((v) {
        productionCountries?.add(ProductionCountries.fromJson(v));
      });
    }
    homepage = json['homepage'];
    id = json['id'];
    imdbId = json['imdb_id'];
    originalLanguage = json['original_language'];
    originalTitle = json['original_title'];
    overview = json['overview'];
    popularity = json['popularity'];
    posterPath = json['poster_path'];
    releaseDate = json['release_date'];
    revenue = json['revenue'];
    runtime = json['runtime'];
    status = json['status'];
    tagline = json['tagline'];
    title = json['title'];
    voteAverage = json['vote_average'];
    voteCount = json['vote_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adult'] = this.adult;
    data['backdrop_path'] = this.backdropPath;
    data['budget'] = this.budget;
    if (this.genres != null) {
      data['genres'] = this.genres!.map((v) => v.toJson()).toList();
    }
    data['homepage'] = this.homepage;
    data['id'] = this.id;
    data['imdb_id'] = this.imdbId;
    data['original_language'] = this.originalLanguage;
    data['original_title'] = this.originalTitle;
    data['overview'] = this.overview;
    data['popularity'] = this.popularity;
    data['poster_path'] = this.posterPath;
    data['release_date'] = this.releaseDate;
    data['revenue'] = this.revenue;
    data['runtime'] = this.runtime;
    data['status'] = this.status;
    data['tagline'] = this.tagline;
    data['title'] = this.title;
    data['vote_average'] = this.voteAverage;
    data['vote_count'] = this.voteCount;
    if (productionCompanies != null) {
      data['production_companies'] =
          productionCompanies?.map((v) => v.toJson()).toList();
    }
    if (productionCountries != null) {
      data['production_countries'] =
          productionCountries?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BelongsToCollection {
  int? id;
  String? name;
  String? posterPath;
  String? backdropPath;
  BelongsToCollection({this.backdropPath, this.id, this.name, this.posterPath});
  BelongsToCollection.fromJson(Map<String, dynamic> json) {
    if (json['belongs_to_collection'] == null) {
      id = null;
      name = null;
      posterPath = null;
      backdropPath = null;
    } else {
      if (json['belongs_to_collection']['id'] != null) {
        id = json['belongs_to_collection']['id'];
      }
      if (json['belongs_to_collection']['name'] != null) {
        name = json['belongs_to_collection']['name'];
      }
      if (json['belongs_to_collection']['poster_path'] != null) {
        posterPath = json['belongs_to_collection']['poster_path'];
      }
      if (json['belongs_to_collection']['backdrop_path'] != null) {
        backdropPath = json['belongs_to_collection']['backdrop_path'];
      }
    }
  }
}

class CollectionMovieList {
  List<Movie>? movies;
  CollectionMovieList({
    this.movies,
  });

  CollectionMovieList.fromJson(Map<String, dynamic> json) {
    if (json['parts'] != null) {
      movies = [];
      json['parts'].forEach((v) {
        movies!.add(Movie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (movies != null) {
      data['parts'] = movies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CollectionDetails {
  String? overview;
  CollectionDetails({this.overview});
  CollectionDetails.fromJson(Map<String, dynamic> json) {
    if (json['overview'] != null) {
      overview = json['overview'];
    }
  }
}
