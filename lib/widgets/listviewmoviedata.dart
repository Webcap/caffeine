import 'package:flutter/material.dart';
import 'package:login/screens/movie_screens/main_movie_display.dart';
import 'package:login/screens/movie_screens/movie_details.dart';
import 'package:login/widgets/moviedetails.dart';

class ListViewDatamovie extends StatelessWidget {
  const ListViewDatamovie({
    Key? key,
    required this.futre,
  }) : super(key: key);

  final Future futre;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futre,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data != null) {
          return SizedBox(
            height: 190,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 15,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => moviedetails(id: snapshot.data[index].id,)),
                      // );
                    },
                    child: Container(
                      width: 115,
                      margin: const EdgeInsets.only(
                          left: 10, right: 5, bottom: 10),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500/${snapshot.data[index].posterPath}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
          );
        } else {
          return SizedBox(
            height: 190,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (context, index) =>
                const SizedBox(width: 2),
                itemBuilder: (context, index) {
                  return Container(
                    width: 115,
                    margin: const EdgeInsets.only(
                        left: 5, right: 10, bottom: 10),
                    child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: Image.asset('assets/custommovieimage.png',fit: BoxFit.cover),),
                  );
                }),
          );
        }
      },
    );
  }
}