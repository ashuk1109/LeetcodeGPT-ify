import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/all_problems.dart';
import 'package:leetcodegptify/View/problem_details.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';

import '../Common/common_animations.dart';

class Bookmarks extends StatefulWidget {
  final List<Problem> allProblems;

  const Bookmarks({Key? key, required this.allProblems}) : super(key: key);

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  final _viewModel = ProblemsViewModel();

  List<Problem> bookmarks = [];
  Drawer? drawer;

  @override
  void initState() {
    // no need to handle internet connectivity, as bookmarks are stored in-memory cache
    fetchData();
    super.initState();
  }

  fetchData() async {
    drawer = await _viewModel.fetchDrawer(context);
    bookmarks = await _viewModel.fetchBoomarks();
  }

  fetchBookmarkList() async {
    bookmarks = await _viewModel.fetchBoomarks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // this is for when user had no bookmarks, and he added them from all problems screen and used the back gesture to navigate back
    fetchBookmarkList();

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

    if (bookmarks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bookmarks"),
        ),
        drawer: drawer,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Huh, seems like you haven't yet bookmarked any stuff!",
              ),
              ElevatedButton(
                child: const Text("Add Bookmarks"),
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                        page: AllProblemsScreen(
                      allProblems: widget.allProblems,
                    )),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Bookmarks"),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            )),
        drawer: drawer,
        body: ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            Problem _problem = bookmarks[index];
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
                subtitle: Text(
                  _problem.difficulty,
                  style: TextStyle(
                      color:
                          CommonUtilityMethods.getColor(_problem.difficulty)),
                ),
                trailing: IconButton(
                  icon: bookmarks.any((element) =>
                          element.questionId == _problem.questionId)
                      ? Icon(
                          Icons.bookmark_add,
                          color:
                              Theme.of(context).brightness == Brightness.light
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
                                allProblems: widget.allProblems,
                              )));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
