import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:intl/intl.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class MovieInfoTable extends StatefulWidget {
  final String? api;
  const MovieInfoTable({Key? key, this.api}) : super(key: key);

  @override
  MovieInfoTableState createState() => MovieInfoTableState();
}

class MovieInfoTableState extends State<MovieInfoTable> {
  Moviedetail? movieDetails;
  final formatCurrency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    moviesApi().fetchMovieDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          movieDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movie Info',
            style: kTextHeaderStyle,
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: movieDetails == null
                    ? detailInfoTableShimmer1(isDark)
                    : DataTable(dataRowHeight: 40, columns: [
                        const DataColumn(
                            label: Text(
                          'Original Title',
                          style: kTableLeftStyle,
                        )),
                        DataColumn(
                          label: Text(
                            movieDetails!.originalTitle!,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ], rows: [
                        DataRow(cells: [
                          const DataCell(Text(
                            'Status',
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(movieDetails!.status!.isEmpty
                              ? 'unknown'
                              : movieDetails!.status!)),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Runtime',
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(movieDetails!.runtime! == 0
                              ? 'N/A'
                              : '${movieDetails!.runtime!} mins')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Spoken language',
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: movieDetails!.spokenLanguages!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        movieDetails!.spokenLanguages!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(movieDetails!
                                                .spokenLanguages!.isEmpty
                                            ? 'N/A'
                                            : '${movieDetails!.spokenLanguages![index].englishName},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Budget',
                            style: kTableLeftStyle,
                          )),
                          DataCell(movieDetails!.budget == 0
                              ? const Text('-')
                              : Text(formatCurrency
                                  .format(movieDetails!.budget!)
                                  .toString())),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Revenue',
                            style: kTableLeftStyle,
                          )),
                          DataCell(movieDetails!.budget == 0
                              ? const Text('-')
                              : Text(formatCurrency
                                  .format(movieDetails!.revenue!)
                                  .toString())),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Tagline',
                            style: kTableLeftStyle,
                          )),
                          DataCell(
                            Text(
                              movieDetails!.tagline!.isEmpty
                                  ? '-'
                                  : movieDetails!.tagline!,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Production companies',
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: movieDetails!.productionCompanies!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movieDetails!
                                        .productionCompanies!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(movieDetails!
                                                .productionCompanies!.isEmpty
                                            ? 'N/A'
                                            : '${movieDetails!.productionCompanies![index].name},'),
                                      );
                                    },
                                  ),
                          )
                              // movieDetails!.productionCompanies!.isEmpty
                              //     ? const Text('-')
                              //     : Text(
                              //         movieDetails!.productionCompanies![0].name!),
                              ),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'Production countries',
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: movieDetails!.productionCountries!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movieDetails!
                                        .productionCountries!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(movieDetails!
                                                .productionCountries!.isEmpty
                                            ? 'N/A'
                                            : '${movieDetails!.productionCountries![index].name},'),
                                      );
                                    },
                                  ),
                          )
                              // movieDetails!.productionCompanies!.isEmpty
                              //     ? const Text('-')
                              //     : Text(
                              //         movieDetails!.productionCountries![0].name!),
                              ),
                        ]),
                      ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
