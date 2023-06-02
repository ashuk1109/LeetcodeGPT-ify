import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/problem_details.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';

class FilteredProblems extends StatefulWidget {
  final List<String> selectedTopicTags;
  final List<String> selectedDifficultyFilter;
  final List<Problem> allProblems;

  const FilteredProblems(
      {Key? key,
      required this.selectedTopicTags,
      required this.selectedDifficultyFilter,
      required this.allProblems})
      : super(key: key);

  @override
  State<FilteredProblems> createState() => _FilteredProblemsState();
}

class _FilteredProblemsState extends State<FilteredProblems> {
  final _viewModel = ProblemsViewModel();

  List<Problem> filteredProblems = [];
  bool isLoading = true;
  List<Problem> bookmarks = [];

  @override
  void initState() {
    super.initState();
    filterResults();
  }

  filterResults() async {
    setState(() {
      isLoading = true;
    });
    bookmarks = await _viewModel.fetchBoomarks();
    filteredProblems = _viewModel.filterProblems(widget.allProblems,
        widget.selectedDifficultyFilter, widget.selectedTopicTags);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || filteredProblems.isEmpty) {
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
        title: widget.selectedTopicTags.length == 1
            ? Text(widget.selectedTopicTags[0])
            : const Text("Filtered List"),
      ),
      body: ListView.builder(
        itemCount: filteredProblems.length,
        itemBuilder: (context, index) {
          Problem problem = filteredProblems[index];
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
              key: Key(problem.questionId),
              title: Text(problem.title),
              subtitle: Wrap(
                children: [
                  ElevatedButton(
                    onPressed: null,
                    child: Text(
                      problem.difficulty,
                      style: TextStyle(
                        color:
                            CommonUtilityMethods.getColor(problem.difficulty),
                      ),
                    ),
                  )
                ],
              ),
              trailing: IconButton(
                icon: bookmarks.any(
                        (element) => element.questionId == problem.questionId)
                    ? const Icon(
                        Icons.bookmark_add,
                        color: Colors.white,
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                onPressed: () async {
                  _viewModel.updateBookmarks(bookmarks, problem);
                  setState(() {});
                },
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProblemDetails(
                      problem: problem,
                      allProblems: widget.allProblems,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
