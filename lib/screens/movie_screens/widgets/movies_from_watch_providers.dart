import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/streaming_service_screen.dart';
import 'package:provider/provider.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);

  static const radiusMd = 16.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const screenPadH = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}

class MoviesFromWatchProviders extends StatefulWidget {
  const MoviesFromWatchProviders({super.key});

  @override
  MoviesFromWatchProvidersState createState() =>
      MoviesFromWatchProvidersState();
}

class MoviesFromWatchProvidersState extends State<MoviesFromWatchProviders> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: _Design.screenPadH,
            right: _Design.screenPadH,
            top: _Design.space2,
            bottom: _Design.space3,
          ),
          child: Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  tr("streaming_services"),
                  style: TextStyle(
                    color: textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 76,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: _Design.screenPadH),
            children: [
              StreamingServicesWidget(
                imagePath: 'assets/images/netflix.png',
                title: 'Netflix',
                providerID: 8,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/amazon_prime.png',
                title: 'Amazon Prime',
                providerID: 9,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/disney_plus.png',
                title: 'Disney plus',
                providerID: 337,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/hulu.png',
                title: 'hulu',
                providerID: 15,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/hbo_max.png',
                title: 'Max',
                providerID: 1899,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/apple_tv.png',
                title: 'Apple TV plus',
                providerID: 350,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/peacock.png',
                title: 'Peacock',
                providerID: 387,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/itunes.png',
                title: 'iTunes',
                providerID: 2,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/youtube.png',
                title: 'YouTube Premium',
                providerID: 188,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/paramount.png',
                title: 'Paramount Plus',
                providerID: 531,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/netflix.png',
                title: 'Netflix Kids',
                providerID: 175,
              ),
              StreamingServicesWidget(
                imagePath: 'assets/images/showtime.png',
                title: 'Showtime',
                providerID: 37,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;

  const StreamingServicesWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.providerID,
  });

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;

    return Padding(
      padding: const EdgeInsets.only(right: _Design.space3),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamingServicesMovies(
                  providerId: providerID,
                  providerName: title,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(_Design.radiusMd),
          child: Container(
            height: 60,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_Design.radiusMd),
              border: Border.all(color: border),
              boxShadow: const [_Design.shadowCard],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: _Design.space3,
              vertical: _Design.space2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(imagePath),
                  height: 44,
                  width: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: _Design.space2),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textPrim,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
