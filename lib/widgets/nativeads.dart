// import 'package:flutter/material.dart';
// import 'package:startapp_sdk/startapp.dart';

// class NativAdsScreen extends StatefulWidget {
//   const NativAdsScreen({Key? key}) : super(key: key);

//   @override
//   State<NativAdsScreen> createState() => _NativAdsScreenState();
// }

// class _NativAdsScreenState extends State<NativAdsScreen> {
//   StartAppNativeAd? _ad;
//   bool _nativeAdIsLoaded = false;

//   @override
//   void initState() {
//     _ad = NativeAd(
//       adUnitId: AdHelper.nativeAdUnitId!,
//       factoryId: 'listTile',
//       request: const AdRequest(),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _ad = ad as NativeAd;
//             _nativeAdIsLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           print('Ad load failed (code=${error.code} message=${error.message})');
//         },
//       ),
//     );

//     _ad?.load();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _ad?.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return (_ad != null && _nativeAdIsLoaded == true)
//         ? Container(
//             margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
//             width: Get.width,
//             height: 80,
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: (getStorage.read('isDarkMode') == true)
//                     ? ColorValues.darkmodesecond
//                     : Colors.grey.shade200,
//               ),
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             child: AdWidget(ad: _ad!),
//           )
//         : Container(
//             height: 0,
//             width: 0,
//             color: Colors.red,
//           );
//   }
// }
