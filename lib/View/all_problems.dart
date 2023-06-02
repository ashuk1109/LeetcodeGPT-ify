import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/filters.dart';
import 'package:leetcodegptify/View/problem_details.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';

class AllProblemsScreen extends StatefulWidget {
  final List<Problem> allProblems;

  const AllProblemsScreen({Key? key, required this.allProblems})
      : super(key: key);

  @override
  State<AllProblemsScreen> createState() => _AllProblemsScreenState();
}

class _AllProblemsScreenState extends State<AllProblemsScreen> {
  final _viewModel = ProblemsViewModel();

  List<Problem> bookmarks = [];
  bool hasInternetConnection = true;
  bool isLoading = false;
  Drawer? drawer;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    drawer = await _viewModel.fetchDrawer(context);
    bookmarks = await _viewModel.fetchBoomarks();
    setState(() {});
  }

  checkForConnectivity() async {
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection = false) {
      isLoading = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Problem> problemList = widget.allProblems;

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
                  checkForConnectivity();
                },
                child: const Wrap(
                  children: [Icon(Icons.refresh), Text(" Try again")],
                )),
          ],
        )),
      );
    }

    if (drawer == null) {
      return const Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: Colors.grey,
            size: 50.0,
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Problems"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FilterScreen(problems: problemList)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              CommonUtilityMethods.showSearchDelegate(problemList, context);
            },
          ),
        ],
      ),
      drawer: drawer,
      body: ListView.builder(
        itemCount: problemList.length,
        itemBuilder: (context, index) {
          Problem _problem = problemList[index];
          return Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              key: Key(_problem.questionId),
              title: Text(_problem.title),
              subtitle: Wrap(
                children: [
                  ElevatedButton(
                    onPressed: null,
                    child: Text(
                      _problem.difficulty,
                      style: TextStyle(
                        color:
                            CommonUtilityMethods.getColor(_problem.difficulty),
                      ),
                    ),
                  )
                ],
              ),
              trailing: IconButton(
                icon: bookmarks.any(
                        (element) => element.questionId == _problem.questionId)
                    ? Icon(
                        Icons.bookmark_add,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                onPressed: () async {
                  _viewModel.updateBookmarks(bookmarks, _problem);
                  setState(() {});
                },
              ),
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProblemDetails(
                              problem: _problem,
                              allProblems: problemList,
                            )));
              },
            ),
          );
        },
      ),
    );
  }
}
