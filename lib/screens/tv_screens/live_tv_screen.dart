// ignore_for_file: use_build_context_synchronously

import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/player/live_player.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/globlal_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  Channels? channels;
  bool enableRetry = false;

  @override
  void initState() {
    loadChannels();
    super.initState();
  }

  void loadChannels() async {
    try {
      setState(() {
        enableRetry = false;
      });
      await fetchChannels(Endpoints.getIPTVEndpoint(
              Provider.of<AppDependencyProvider>(context, listen: false)
                  .caffeineAPIURL))
          .then((value) {
        setState(() {
          channels = value;
        });
      });
    } on Exception catch (e) {
      setState(() {
        enableRetry = true;
      });
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("channels"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: enableRetry
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.link_off_rounded,
                        size: 35,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Text(
                        tr("channels_fetch_failed"),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        loadChannels();
                      },
                      child: Text(tr("retry")))
                ],
              )
            : channels == null
                ? const Center(child: CircularProgressIndicator())
                : channels!.channels!.isEmpty
                    ? Center(
                        child: Text(
                          tr("no_channels"),
                          style: kTextHeaderStyle,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: channels!.channels!.length,
                        itemBuilder: (context, index) {
                          return ChannelWidget(
                            channel: channels!,
                            index: index,
                          );
                        },
                      ),
      ),
    );
  }
}

class ChannelWidget extends StatefulWidget {
  const ChannelWidget({Key? key, required this.channel, required this.index})
      : super(key: key);

  final Channels channel;
  final int index;

  @override
  State<ChannelWidget> createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final mixpanel =
                Provider.of<SettingsProvider>(context, listen: false).mixpanel;
            final autoFS = Provider.of<SettingsProvider>(context, listen: false)
                .defaultViewMode;
            mixpanel.track('Most viewed TV channels', properties: {
              'TV Channel name':
                  widget.channel.channels![widget.index].channelName ?? "N/A",
            });
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return LivePlayer(
                channelName:
                    widget.channel.channels![widget.index].channelName!,
                videoUrl: widget.channel.baseUrl! +
                    widget.channel.channels![widget.index].channelId!
                        .toString() +
                    widget.channel.trailingUrl!,
                referrer: widget.channel.referrer!,
                autoFullScreen: autoFS,
                userAgent: widget.channel.userAgent!,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.background
                ],
              );
            })));
          },
          child: Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.all(8.0),
            color: Colors.transparent,
            alignment: Alignment.centerLeft,
            child: Text(widget.channel.channels![widget.index].channelName!),
          ),
        ),
        const Divider(
          thickness: 2,
        )
      ],
    );
  }
}

// class ChannelList extends StatefulWidget {
//   const ChannelList({Key? key, required this.catName}) : super(key: key);

//   final String catName;

//   @override
//   State<ChannelList> createState() => _ChannelListState();
// }

// class _ChannelListState extends State<ChannelList> {
//   List<Channel>? channels;

//   @override
//   void initState() {
//     fetchChannels(
//             'https://raw.githubusercontent.com/Webcap/caffiene_live_channels/main/${widget.catName}.json')
//         .then((value) {
//       setState(() {
//         channels = value;
//       });
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           tr("channels"),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: channels == null
//             ? const Center(child: CircularProgressIndicator())
//             : channels!.isEmpty
//                 ? Center(
//                     child: Text(
//                       tr("no_channels"),
//                       style: kTextHeaderStyle,
//                       maxLines: 2,
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 : Column(
//                     children: [
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: channels!.length,
//                           itemBuilder: (context, index) {
//                             return ChannelWidget(
//                               channel: channels![index],
//                               catName: widget.catName,
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//       ),
//     );
//   }
// }

// class _ChannelWidgetState extends State<ChannelWidget> {
//   Map<String, String> videos = {};
//   Map<String, String> reversedVids = {};

//   late AppDependencyProvider appDep =
//       Provider.of<AppDependencyProvider>(context, listen: false);
//   late bool showAD;

//   void sett() {
//     for (int k = 0; k < widget.channel.channelStream!.length; k++) {
//       videos.addAll({
//         widget.channel.channelStream![k].videoQuality!:
//             widget.channel.channelStream![k].streamLink!,
//       });

//       List<MapEntry<String, String>> reversedVideoList =
//           videos.entries.toList().reversed.toList();
//       reversedVids = Map.fromEntries(reversedVideoList);
//     }
//   }

//   @override
//   void initState() {
//     sett();
//     if (appDep.enableADS) {
//       loadInterstitialAd();
//     }
//     super.initState();
//   }

//   var startAppSdk = StartAppSdk();
//   StartAppInterstitialAd? interstitialAd;

//   Future<void> loadInterstitialAd() async {
//     startAppSdk
//         .loadInterstitialAd()
//         .then((interstitialAd) {
//           setState(() {
//             this.interstitialAd = interstitialAd;
//           });
//         })
//         .onError<StartAppException>((ex, stackTrace) {})
//         .onError((error, stackTrace) {});
//   }

//   bool shouldShowADS() {
//     Random random = Random();
//     int randomNumber = random.nextInt(4);
//     return randomNumber == 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 showAD = shouldShowADS();
//               });
//               final mixpanel =
//                   Provider.of<SettingsProvider>(context, listen: false)
//                       .mixpanel;
//               final autoFS =
//                   Provider.of<SettingsProvider>(context, listen: false)
//                       .defaultViewMode;
//               mixpanel.track('Most viewed TV channels', properties: {
//                 'TV Channel name': widget.channel.channelName,
//                 'Category': widget.catName,
//               });
//               if (interstitialAd != null && showAD) {
//                 interstitialAd!.show();
//                 loadInterstitialAd().whenComplete(() => Navigator.push(context,
//                         MaterialPageRoute(builder: ((context) {
//                       return LivePlayer(
//                         channelName: widget.channel.channelName!,
//                         sources: reversedVids,
//                         autoFullScreen: autoFS,
//                         colors: [
//                           Theme.of(context).primaryColor,
//                           Theme.of(context).colorScheme.background
//                         ],
//                       );
//                     }))));
//               } else {
//                 Navigator.push(context, MaterialPageRoute(builder: ((context) {
//                   return LivePlayer(
//                     channelName: widget.channel.channelName!,
//                     sources: reversedVids,
//                     autoFullScreen: autoFS,
//                     colors: [
//                       Theme.of(context).primaryColor,
//                       Theme.of(context).colorScheme.background
//                     ],
//                   );
//                 })));
//               }
//             },
//             child: Container(
//               height: 60,
//               color: Colors.transparent,
//               child: Row(
//                 children: [
//                   SizedBox(
//                     height: 60,
//                     width: 70,
//                     child: CachedNetworkImage(
//                       cacheManager: cacheProp(),
//                       fadeOutDuration: const Duration(milliseconds: 300),
//                       fadeOutCurve: Curves.easeOut,
//                       fadeInDuration: const Duration(milliseconds: 700),
//                       fadeInCurve: Curves.easeIn,
//                       imageUrl: widget.channel.channelLogo!,
//                       placeholder: (context, url) =>
//                           Image.asset('assets/images/loading_5.gif'),
//                       errorWidget: (context, url, error) => Image.asset(
//                         'assets/images/na_rect.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   Text(widget.channel.channelName!)
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const Divider(
//           thickness: 2,
//         )
//       ],
//     );
//   }
// }

// /*





// Center(
//         child: ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 maxBuffer =
//                     Provider.of<SettingsProvider>(context, listen: false)
//                         .defaultMaxBufferDuration;
//                 seekDuration =
//                     Provider.of<SettingsProvider>(context, listen: false)
//                         .defaultSeekDuration;
//                 videoQuality =
//                     Provider.of<SettingsProvider>(context, listen: false)
//                         .defaultVideoResolution;
//               });
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return LivePlayer(sources: {
//                   'auto': 'http://45.12.1.14:80/7JvIck488/meAqNw5218/28903'
//                 }, colors: [
//                   Theme.of(context).primaryColor,
//                   Theme.of(context).colorScheme.background
//                 ], videoProperties: [
//                   maxBuffer,
//                   seekDuration,
//                   videoQuality
//                 ]);
//               }));
//             },
//             child: Text('PLAY')),
//       ),






//  */


// /*

// GridView.count(
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 10,
//                 childAspectRatio: 2,
//                 shrinkWrap: true,
//                 crossAxisCount: 2, // Maximum of 3 items horizontally
//                 children: List.generate(categories.length, (index) {
//                   return GridTile(
//                     child: Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.primary,
//                           borderRadius: BorderRadius.circular(30)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: CategoryWidget(category: categories[index]),
//                       ),
//                     ),
//                   );
//                 }),
//               )

//  */
