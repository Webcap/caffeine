// ignore_for_file: unused_local_variable

import 'package:caffiene/models/profile_modal.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/screens/common/landing_screen.dart';
import 'package:caffiene/screens/common/subscribe_to_premium.dart';
import 'package:caffiene/utils/app_colors.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:caffiene/utils/textStyle.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? uid;
  bool? userAnonymous;
  DocumentSnapshot? userDoc;
  String? month;
  int? year;

  @override
  void initState() {
    getData();
    rtData();
    super.initState();
  }

  void getData() async {
    User? user = _auth.currentUser;
    uid = user!.uid;
    final sp = context.read<SignInProvider>();

    if (user.isAnonymous) {
      if (mounted) {
        setState(() {
          userAnonymous = true;
        });
      }
    } else {
      userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          userAnonymous = false;
        });
      }
    }
  }

  void rtData() {
    // FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(uid)
    //     .snapshots()
    //     .listen((DocumentSnapshot documentSnapshot) {
    //   Map<String, dynamic> firestoreInfo =
    //       documentSnapshot as Map<String, dynamic>;

    //   setState(() {
    //     String money = firestoreInfo['earnings'];
    //     print(money);
    //   });
    // }).onError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final sp = context.watch<SignInProvider>();
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return userAnonymous == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : userAnonymous == true
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'This current account is anonymous, signup or login to access this page',
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await _auth.currentUser!.delete().then((value) async {
                            await _auth.signOut().then((value) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const LandingScreen();
                              })));
                            });
                          });
                        },
                        child: const Text('Login/Signup'))
                  ],
                ),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    const Center(
                      child: Text('Error occured :('),
                    );
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: SizeConfig.blockSizeHorizontal * 4,
                        top: SizeConfig.blockSizeVertical * 3,
                        right: SizeConfig.blockSizeHorizontal * 3,
                      ),
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: SizeConfig.blockSizeVertical * 4,
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(80),
                                      child: snapshot.data!['image_url'] != ""
                                          ? Image.network(
                                              snapshot.data!['image_url'],
                                              width: 80,
                                              height: 80,
                                            )
                                          : Image.asset(
                                              'assets/images/profiles/${snapshot.data!['profileId']}.png',
                                              width: 80,
                                              height: 80,
                                            )),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 2,
                                  ),
                                  // USERNAME //
                                  Text(
                                    snapshot.data!['name'] ?? 'caffeineUser123',
                                    style: titalstyle1,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Provider: ${snapshot.data!['provider']}"
                                        .toUpperCase(),
                                    style: titalstyle2,
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                      'Joined: ${DateFormat('MMMM').format(DateTime(0, DateTime.parse(snapshot.data!['joinedAt']).month))} ${DateTime.parse(snapshot.data!['joinedAt']).year}'),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 5,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            snapshot.data!['email'] ??
                                                'caffeineUser123',
                                            style: titalstyle2,
                                          ),
                                          Visibility(
                                              visible:
                                                  snapshot.data!['verified'] ??
                                                      false,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: SvgPicture.asset(
                                                  'assets/images/checkmark.svg',
                                                  width: 20,
                                                  height: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 2,
                                  ),

                                  /// SubscribetoPremium ///
                                  // (snapshot.data!['isSubscribed'] == false)
                                  //     ? GestureDetector(
                                  //         onTap: () {
                                  //           Get.to(
                                  //             () => const SubscribeToPremium(),
                                  //             transition: Transition.downToUp,
                                  //           );
                                  //         },
                                  //         child: Container(
                                  //           width:
                                  //               SizeConfig.screenWidth / 1.15,
                                  //           padding: const EdgeInsets.all(15),
                                  //           decoration: BoxDecoration(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(22),
                                  //             border: Border.all(
                                  //               width: 1.5,
                                  //               color: Theme.of(context)
                                  //                   .colorScheme
                                  //                   .primary,
                                  //             ),
                                  //           ),
                                  //           child: Row(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment
                                  //                     .spaceBetween,
                                  //             children: [
                                  //               Image.asset(
                                  //                 MovixIcon.king,
                                  //                 color: Theme.of(context)
                                  //                     .colorScheme
                                  //                     .primary,
                                  //                 height: SizeConfig
                                  //                         .blockSizeVertical *
                                  //                     5,
                                  //                 width: SizeConfig
                                  //                         .blockSizeVertical *
                                  //                     5,
                                  //               ),
                                  //               Column(
                                  //                 crossAxisAlignment:
                                  //                     CrossAxisAlignment.start,
                                  //                 children: [
                                  //                   Text(
                                  //                     "Join Premium!",
                                  //                     style:
                                  //                         GoogleFonts.urbanist(
                                  //                       fontWeight:
                                  //                           FontWeight.bold,
                                  //                       fontSize: 19,
                                  //                       color: Theme.of(context)
                                  //                           .colorScheme
                                  //                           .primary,
                                  //                     ),
                                  //                   ),
                                  //                   SizedBox(
                                  //                     height: SizeConfig
                                  //                             .blockSizeVertical *
                                  //                         0.7,
                                  //                   ),
                                  //                   Text(
                                  //                     "Enjoy watching Premium Movie",
                                  //                     style:
                                  //                         GoogleFonts.urbanist(
                                  //                       fontSize: 11,
                                  //                       fontWeight:
                                  //                           FontWeight.w500,
                                  //                       color: themeMode ==
                                  //                                   "dark" ||
                                  //                               themeMode ==
                                  //                                   "amoled"
                                  //                           ? Colors.white
                                  //                           : Colors.black,
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //               SvgPicture.asset(
                                  //                 MovixIcon.smallArrowRight,
                                  //                 height: SizeConfig
                                  //                         .blockSizeVertical *
                                  //                     3,
                                  //                 color: Theme.of(context)
                                  //                     .colorScheme
                                  //                     .primary,
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : GestureDetector(
                                  //         child: Container(
                                  //           width:
                                  //               SizeConfig.screenWidth / 1.15,
                                  //           padding: const EdgeInsets.all(15),
                                  //           decoration: BoxDecoration(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(22),
                                  //             border: Border.all(
                                  //               width: 1.5,
                                  //               color: Theme.of(context)
                                  //                   .colorScheme
                                  //                   .primary,
                                  //             ),
                                  //           ),
                                  //           child: Row(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.spaceAround,
                                  //             children: [
                                  //               Image.asset(
                                  //                 MovixIcon.king,
                                  //                 color: Theme.of(context)
                                  //                     .colorScheme
                                  //                     .primary,
                                  //                 height: SizeConfig
                                  //                         .blockSizeVertical *
                                  //                     5,
                                  //                 width: SizeConfig
                                  //                         .blockSizeVertical *
                                  //                     5,
                                  //               ),
                                  //               Column(
                                  //                 crossAxisAlignment:
                                  //                     CrossAxisAlignment.start,
                                  //                 children: [
                                  //                   // TODO translate
                                  //                   Text(
                                  //                     "You're Subscribed",
                                  //                     style:
                                  //                         GoogleFonts.urbanist(
                                  //                       fontWeight:
                                  //                           FontWeight.bold,
                                  //                       fontSize: 17,
                                  //                       color: Theme.of(context)
                                  //                           .colorScheme
                                  //                           .primary,
                                  //                     ),
                                  //                   ),
                                  //                   SizedBox(
                                  //                     height: SizeConfig
                                  //                             .blockSizeVertical *
                                  //                         0.7,
                                  //                   ),
                                  //                   Text(
                                  //                     "Enjoying Premium Benefits",
                                  //                     style:
                                  //                         GoogleFonts.urbanist(
                                  //                       fontSize: 13,
                                  //                       color: themeMode ==
                                  //                                   "dark" ||
                                  //                               themeMode ==
                                  //                                   "amoled"
                                  //                           ? ColorValues
                                  //                               .whiteColor
                                  //                           : const Color(
                                  //                               0xFF616161),
                                  //                       fontWeight:
                                  //                           FontWeight.w500,
                                  //                     ),
                                  //                   )
                                  //                 ],
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),

                                  // end premium block //
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 2,
                                  ),

                                  // Profile Tab //
                                  ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: settingdata.length,
                                      itemBuilder: (context, i) {
                                        return GestureDetector(
                                          onTap: settingdata[i].onTap,
                                          child: Container(
                                            color: Colors.transparent,
                                            padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal *
                                                  2.5,
                                              right: SizeConfig
                                                      .blockSizeHorizontal *
                                                  3,
                                              top:
                                                  SizeConfig.blockSizeVertical *
                                                      2.5,
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  settingdata[i].iconImage,
                                                  color: themeMode == "dark" ||
                                                          themeMode == "amoled"
                                                      ? ColorValues.whiteColor
                                                      : ColorValues.blackColor,
                                                  height: SizeConfig
                                                          .blockSizeVertical *
                                                      3,
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal *
                                                      2,
                                                ),
                                                Text(
                                                  settingdata[i].tital,
                                                  style: GoogleFonts.urbanist(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const Spacer(),
                                                (settingdata[i].subTital ==
                                                        null)
                                                    ? Container()
                                                    : Text(
                                                        "${settingdata[i].subTital}",
                                                        style: GoogleFonts
                                                            .urbanist(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: SizeConfig
                                                          .blockSizeVertical *
                                                      2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 1.5,
                                  ),

                                  //Logout Button//

                                  GestureDetector(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: SizeConfig.blockSizeHorizontal *
                                              4),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            MovixIcon.logOut,
                                            height:
                                                SizeConfig.blockSizeVertical *
                                                    2.5,
                                            color: ColorValues.redColor,
                                          ),
                                          SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal *
                                                    2,
                                          ),
                                          Text(
                                            "Logout",
                                            style: GoogleFonts.urbanist(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFF75555),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Get.bottomSheet(
                                          backgroundColor:
                                              themeMode == "dark" ||
                                                      themeMode == "amoled"
                                                  ? ColorValues.darkmodesecond
                                                  : ColorValues.whiteColor,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40),
                                            topRight: Radius.circular(40),
                                          )),
                                          Container(
                                            padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal *
                                                  3,
                                              right: SizeConfig
                                                      .blockSizeHorizontal *
                                                  3,
                                            ),
                                            height: SizeConfig.screenHeight / 3,
                                            decoration: BoxDecoration(
                                              color: themeMode == "dark" ||
                                                      themeMode == "amoled"
                                                  ? ColorValues.darkmodesecond
                                                  : ColorValues.whiteColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(45),
                                                topLeft: Radius.circular(45),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal *
                                                      13,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                    color: ColorValues.boxColor,
                                                  ),
                                                ),
                                                Text(
                                                  "Logout",
                                                  style: GoogleFonts.urbanist(
                                                      fontSize: 22,
                                                      color:
                                                          ColorValues.redColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Divider(
                                                  color: Colors.grey,
                                                  indent: 15,
                                                  endIndent: 15,
                                                ),
                                                Text(
                                                  "Are you sure you want to log out?",
                                                  style: GoogleFonts.urbanist(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical *
                                                      0.06,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Container(
                                                        height: SizeConfig
                                                                .screenHeight /
                                                            16,
                                                        width: SizeConfig
                                                                .screenWidth /
                                                            2.5,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          color: themeMode ==
                                                                      "dark" ||
                                                                  themeMode ==
                                                                      "amoled"
                                                              ? const Color(
                                                                  0xff35383F)
                                                              : ColorValues
                                                                  .redBoxColor,
                                                        ),
                                                        child: Text(
                                                          "Cancel",
                                                          style: GoogleFonts
                                                              .urbanist(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: themeMode == "dark" ||
                                                                    themeMode ==
                                                                        "amoled"
                                                                ? ColorValues
                                                                    .whiteColor
                                                                : ColorValues
                                                                    .redColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: SizeConfig
                                                                .screenHeight /
                                                            16,
                                                        width: SizeConfig
                                                                .screenWidth /
                                                            2.5,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          color: ColorValues
                                                              .redColor,
                                                        ),
                                                        child: Text(
                                                          "Yes, Logout",
                                                          style: GoogleFonts
                                                              .urbanist(
                                                            color: ColorValues
                                                                .whiteColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        sp.userSignOut();
                                                        print("logging out");
                                                        Get.back();
                                                        Get.offNamed(Routes
                                                            .landingScreen);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ));
                                    },
                                  ),
                                  const SizedBox(
                                    height: 100,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
  }
}
