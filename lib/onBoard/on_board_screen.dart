import 'package:flutter/material.dart';
import 'package:flutter_gsheet/login_page.dart';
import 'package:flutter_gsheet/onBoard/AllinOnboardModel.dart';

class OnboardScreen extends StatefulWidget {
  OnboardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int currentIndex = 0;
  PageController pageController=PageController();

  List<AllinOnboardModel> allinonboardlist = [
    AllinOnboardModel(
        "assets/goal.png",
        "Developing disruptive solutions, require collaborative efforts from great tech talents across the globe. A right team behind a project increases the chances of its success by 70%. Our vision is to help new-age companies scale up their technological capabilities by providing on-demand access to world-class talent.",
        "We Put Together Your Dream-Team"),
    AllinOnboardModel(
        "assets/value.png",
        "We use our Values every day, whether we’re discussing ideas for new projects or deciding on the best approach to solving a problem. It is just one of the things that makes ScaleupAlly peculiar.",
        "Our Values"),
    AllinOnboardModel(
        "assets/productivity.png",
        "Access to the top talents at the right time with little to no-management needed, can potentially double your overall productivity",
        "2X Productivity"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Scaleupally",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(flex: 7,
            child: PageView.builder(controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                itemCount: allinonboardlist.length,
                itemBuilder: (context, index) {
                  return PageBuilderWidget(
                      title: allinonboardlist[index].titlestr,
                      description: allinonboardlist[index].description,
                      imgurl: allinonboardlist[index].imgStr);
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              allinonboardlist.length,
                  (index) => buildDot(index: index),
            ),
          ),
          SizedBox(height: 16,),

          currentIndex < allinonboardlist.length - 1
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Previous",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0))),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // pageController.animateTo(1, duration: Duration.zero, curve: Curves.easeIn);
                      currentIndex++;
                      pageController.jumpToPage(currentIndex);
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0))),
                    ),
                  )
                ],
              )
              :
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>LoginPage()));
                    },
                    child: Text(
                      "Get Started",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
            ],
          ),

          SizedBox(height: 16,)
        ],
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentIndex == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.blueAccent : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  String title;
  String description;
  String imgurl;
  PageBuilderWidget(
      {Key? key,
        required this.title,
        required this.description,
        required this.imgurl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child:Image.asset(imgurl),
          ),
          const SizedBox(
            height: 20,
          ),
          //Tite Text
          Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
          const SizedBox(
            height: 20,
          ),
          //discription
          Text(description,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ))
        ],
      ),
    );
  }
}