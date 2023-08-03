import 'package:flutter/material.dart';

class HomeLoadingWidget extends StatelessWidget {
  const HomeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {

      return Positioned(
        bottom: 0,
        left: 45,
        right: 45,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height:  MediaQuery.of(context).size.height -70,
          child: Container(
            child: Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      margin:  EdgeInsets.only(right: MediaQuery.of(context).size.width/5),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Container(
                            width: 300,
                            height: 50,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 45,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 110,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 55,
                                height: 18,
                                color: Colors.white70,
                              ),

                              const SizedBox(width: 5),
                              Container(
                                width: 40,
                                height: 18,
                                color: Colors.white70,
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),

                              const SizedBox(width: 5),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 70,
                                height: 18,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                          const SizedBox(height: 27),
                          Container(
                            width: 600,
                            height: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 600,
                            height: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 600,
                            height: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 600,
                            height: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: 400,
                            height: 12,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      right: 5,
                      bottom: 15,
                      child: Container(
                        height: 35,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          color: Colors.white70,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 35,
                              width: 35,
                              decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(width: 1,color:Colors.black12))
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      bottom: 0,
                      child: Container(

                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),

                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.white70,
                                  border: Border(right: BorderSide(width: 1,color:Colors.black12))
                              ),
                            ),

                            const SizedBox(width: 5),
                            Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(

                                  color: Colors.white70,
                                  border: Border(right: BorderSide(width: 1,color:Colors.black12))
                              ),
                            ),

                            const SizedBox(width: 5),
                            Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(

                                  color: Colors.white70,
                                  border: Border(right: BorderSide(width: 1,color:Colors.black12))
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              height: 10,
                              width: 20,
                              decoration: const BoxDecoration(

                                  color: Colors.white70,
                                  border: Border(right: BorderSide(width: 1,color:Colors.black12))
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 7,top: 10),
                  child: Container(
                    color: Colors.white70,
                    width: 100,
                    height: 20,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white70,
                          height: 65,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          color: Colors.white70,
                          height: 65,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          color: Colors.white70,
                          height: 65,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          color: Colors.white70,
                          height: 65,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          color: Colors.white70,
                          height: 65,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          color: Colors.white70,
                          height: 65,
                        ),
                      ),


                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 7,top: 0),
                  child: Container(
                    color: Colors.white70,
                    width: 100,
                    height: 20,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );

  }
}
