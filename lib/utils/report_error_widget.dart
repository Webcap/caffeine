import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportErrorWidget extends StatelessWidget {
  const ReportErrorWidget({
    Key? key,
    required this.error,
  }) : super(key: key);

  final String error;
  //final List metadata;

  @override
  Widget build(BuildContext context) {
    // String meta = "";
    // for (int i = 0; i < metadata.length; i++) {
    //   meta += metadata[i].toString();
    // }
    // String url =
    //     "https://t.me/share/url?url=FlixQuest error&text=${error}\n${meta}";
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              error,
              maxLines: 6,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse("https://t.me/flixquestgroup"),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.telegram),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        tr("report_telegram"),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
