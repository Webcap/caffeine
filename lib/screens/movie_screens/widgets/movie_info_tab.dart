import 'package:caffiene/utils/theme/textStyle.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/movie_models.dart';
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
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  tr("movie_info"),
                  style: kTextHeaderStyle,
                ),
              ),
            ],
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: movieDetails == null
                    ? detailInfoTableShimmer(themeMode)
                    : DataTable(dataRowMinHeight: 40, columns: [
                        DataColumn(
                            label: Text(
                          tr("original_title"),
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
                          DataCell(Text(
                            tr("status"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(movieDetails!.status!.isEmpty
                              ? tr("unknown")
                              : movieDetails!.status!)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("runtime"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(movieDetails!.runtime! == 0
                              ? tr("not_available")
                              : tr("runtime_mins", namedArgs: {
                                  "mins": movieDetails!.runtime!.toString()
                                }))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("spoken_language"),
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
                                            ? tr("not_available")
                                            : '${movieDetails!.spokenLanguages![index].englishName},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("budget"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(movieDetails!.budget == 0
                              ? const Text('-')
                              : Text(formatCurrency
                                  .format(movieDetails!.budget!)
                                  .toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("revenue"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(movieDetails!.budget == 0
                              ? const Text('-')
                              : Text(formatCurrency
                                  .format(movieDetails!.revenue!)
                                  .toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("tagline"),
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
                          DataCell(Text(
                            tr("production_companies"),
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
                                            ? tr("not_available")
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
                          DataCell(Text(
                            tr("production_countries"),
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
                                            ? tr("not_available")
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
