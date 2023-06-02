import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/all_problems.dart';
import 'package:leetcodegptify/View/contests.dart';
import 'package:leetcodegptify/View/notes_screen.dart';
import 'package:leetcodegptify/View/problem_details.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';
import 'package:pie_chart/pie_chart.dart';

import '../Common/common_animations.dart';
import 'bookmarks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _viewModel = ProblemsViewModel();

  List<Problem> mediumProblemList = [];
  List<Problem> allProblems = [];
  Problem problemOfTheDay = ProblemsViewModel.dummyProblem;
  int easyCount = 0, midCount = 0, hardCount = 0;
  Map<String, double> dataMap = {};
  bool hasInternetConnection = true;
  bool isLoading = false;

  Drawer? drawer;

  @override
  void initState() {
    getThingsReady();
    super.initState();
  }

  getThingsReady() async {
    setState(() {
      isLoading = true;
    });
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection == false) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    await initializeData();
    await fetchDrawer();
    setState(() {
      isLoading = false;
    });
  }

  fetchDrawer() async {
    drawer = await _viewModel.fetchDrawer(context);
    setState(() {});
  }

  initializeData() async {
    allProblems = await _viewModel.getAllProblems();

    if (allProblems.length <= 1) {
      return;
    }
    await initializeDataMap();
  }

  Future<void> initializeDataMap() async {
    mediumProblemList = _viewModel.getProblemList(allProblems, "Medium");
    midCount = mediumProblemList.length;
    easyCount = _viewModel.getProblemList(allProblems, "Easy").length;
    hardCount = _viewModel.getProblemList(allProblems, "Hard").length;
    problemOfTheDay = _viewModel.getProblemOfTheDay(mediumProblemList);
    dataMap = {
      "Easy": easyCount.toDouble(),
      "Medium": midCount.toDouble(),
      "Hard": hardCount.toDouble(),
    };
  }

  Future<void> fetchProblemsFromAPI() async {
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection == false) {
      setState(() {});
      return;
    }
    allProblems = await _viewModel.fetchAllProblemsFromAPI();
    await initializeDataMap();
    await fetchDrawer();
  }

  @override
  Widget build(BuildContext context) {
    if (allProblems.length == 1 && allProblems[0].questionId == "-10" ||
        allProblems.isEmpty) {
      //if cache was corrupted or on first startup the network request couldn't be fulfilled
      setState(() {
        isLoading = true;
      });
      fetchProblemsFromAPI();
      setState(() {
        isLoading = false;
      });
    }

    if (hasInternetConnection == false) {
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No internet connection! \n"
              "Please check your internet connectivity and try again",
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, SlidePageRoute(page: const HomeScreen()));
                },
                child: const Wrap(
                  children: [Icon(Icons.refresh), Text(" Try again")],
                )),
          ],
        )),
      );
    }

    if (dataMap.isEmpty ||
        problemOfTheDay.title == "" ||
        drawer == null ||
        isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("LeetcodeGPT-ify"),
          ),
          body: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCircle(
                color: Colors.grey,
                size: 50.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text("Getting things ready for you ...")
            ],
          ));
    }

    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("LeetcodeGPT-ify"),
          ),
          drawer: drawer,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 10,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          "Problem Of The Day !!",
                          speed: const Duration(milliseconds: 100),
                          textStyle: const TextStyle(fontSize: 20.0),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      totalRepeatCount: 5,
                      pause: const Duration(seconds: 1),
                    ),
                  ),
                ),
                SizedBox(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      key: Key(problemOfTheDay.questionId),
                      title: Text(
                        problemOfTheDay.title,
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Center(
                        child: Wrap(
                          children: [
                            ElevatedButton(
                              onPressed: null,
                              child: Text(
                                problemOfTheDay.difficulty,
                                style: const TextStyle(
                                  color: Colors.orange,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProblemDetails(
                                      problem: problemOfTheDay,
                                      allProblems: allProblems,
                                    )));
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35 / 10,
                ),
                PieChart(
                  dataMap: dataMap,
                  colorList: _viewModel.colorList,
                  chartType: ChartType.ring,
                  chartRadius: MediaQuery.of(context).size.height / 4,
                  chartValuesOptions:
                      const ChartValuesOptions(decimalPlaces: 0),
                  centerText: "Problems",
                  animationDuration: const Duration(seconds: 2),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35 / 10,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_sharp),
                    Text("Quick Access"),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Row(
                              children: [
                                Icon(Icons.list_alt_outlined),
                                Text("  All Problems"),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  HomeScreenZoomInPageRoute(
                                      page: AllProblemsScreen(
                                    allProblems: allProblems,
                                  )));
                            },
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          ElevatedButton(
                            child: const Row(
                              children: [
                                Icon(Icons.bookmark_border_outlined),
                                Text("  Bookmarks"),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  HomeScreenZoomInPageRoute(
                                      page: Bookmarks(
                                    allProblems: mediumProblemList,
                                  )));
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              child: const Row(
                                children: [
                                  Icon(Icons.search_outlined),
                                  Text("  Search Problems"),
                                ],
                              ),
                              onPressed: () {
                                CommonUtilityMethods.showSearchDelegate(
                                    allProblems, context);
                              }),
                          const SizedBox(
                            width: 10.0,
                          ),
                          ElevatedButton(
                            child: const Row(
                              children: [
                                Icon(Icons.notes),
                                Text("  Notes"),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  HomeScreenZoomInPageRoute(
                                      page: NotesScreen(
                                    allProblems: allProblems,
                                  )));
                            },
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Row(
                              children: [
                                Icon(Icons.schedule_rounded),
                                Text("  Upcoming Contests"),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  HomeScreenZoomInPageRoute(
                                      page: const ContestScreen()));
                            },
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
