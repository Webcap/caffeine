import 'package:flutter/material.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/widgets/custom_navbar.dart';
import 'package:login/widgets/new_movie_widgets.dart';
import 'package:login/widgets/upcoming_widget.dart';
import 'package:provider/provider.dart';

class dash_screen extends StatefulWidget {
  dash_screen({Key? key}) : super(key: key);

  @override
  State<dash_screen> createState() => _dash_screenState();
}

class _dash_screenState extends State<dash_screen> {
  
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      backgroundColor: Color(0xFF0F111D),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          "Hello ${sp.name}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500
                          )
                        ),
                        Text("What are we watching?",
                        style: TextStyle(
                            color: Colors.white54,
                        ))
                      ]
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage("${sp.imageUrl}"),
                      radius: 30,
                    ),
                  ]
                ),
              ),
              Container(
                height: 60,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF292837),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search, 
                      color: Colors.white54, 
                      size: 30,
                    ),
                    Container(
                      width: 300,
                      margin: EdgeInsets.only(left: 5),
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30,),
              UpcomingWidget(),
              SizedBox(height: 40,),
              NewMoviesWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}