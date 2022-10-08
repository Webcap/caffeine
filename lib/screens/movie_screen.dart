import 'package:flutter/material.dart';
import 'package:login/widgets/custom_navbar.dart';
import 'package:login/widgets/movie_page_buttons.dart';
import 'package:login/widgets/movie_rec.dart';

class movie_screen extends StatefulWidget {
  const movie_screen({Key? key}) : super(key: key);

  @override
  State<movie_screen> createState() => _movie_screenState();
}

class _movie_screenState extends State<movie_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F111D),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: Image.asset(
              "assets/c1.jpg",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        //favorit button
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset("assets/n9.jpg",
                                  height: 250, width: 180),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 50, top: 70),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 60,
                            ),
                          )
                        ],
                      )),
                  SizedBox(height: 30),
                  MoviePageButtons(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Blonde",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 15),
                        Text(
                            "A look at the rise to fame and the epic demise of actress Marilyn Monroe, one of the biggest stars in the world.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.justify,
                          )
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  MovieRecommendWidget()
                ],
              ),
            ),
          )
        ],
      ),
      //bottomNavigationBar: CustomNavBar(),
    );
  }
}
