import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leetcodegptify/Common/tags.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/filtered_problem_list.dart';

class FilterScreen extends StatefulWidget {
  final List<Problem> problems;

  const FilterScreen({Key? key, required this.problems}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final List<String> difficultyFilter = ["All", "Easy", "Medium", "Hard"];
  final List<String> selectedDifficultyFilter = [];
  final List<String> topicTags = tags;
  final List<String> selectedTopicTags = [];

  setFilter(String filter, bool selected) {
    if (filter == "All") {
      if (selected) {
        selectedDifficultyFilter.addAll(difficultyFilter);
      } else {
        selectedDifficultyFilter.clear();
      }
    } else {
      if (selected) {
        selectedDifficultyFilter.add(filter);
      } else {
        selectedDifficultyFilter.remove(filter);
      }
    }
  }

  setTopic(String filter, bool selected) {
    if (selected) {
      selectedTopicTags.add(filter);
    } else {
      selectedTopicTags.remove(filter);
    }
  }

  bool validateFilterSelection() {
    // 3 false cases are possible -
    // 1. Both difficulty and topic filters are empty.
    // 2. Only difficulty filter is empty.
    // 3. Only topic filter is empty.
    if (selectedDifficultyFilter.isEmpty && selectedTopicTags.isEmpty) {
      // case 1
      Fluttertoast.showToast(
          msg:
              "Please select atleast one difficulty and topic filter to proceed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return false;
    } else if (selectedDifficultyFilter.isEmpty &&
        selectedTopicTags.isNotEmpty) {
      // case 2
      Fluttertoast.showToast(
          msg: "Please select atleast one difficulty level to proceed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return false;
    } else if (selectedDifficultyFilter.isNotEmpty &&
        selectedTopicTags.isEmpty) {
      // case 3
      Fluttertoast.showToast(
          msg: "Please select atleast one topic to proceed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 5 / 7,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Difficulty',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (String filter in difficultyFilter)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 5.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: selectedDifficultyFilter.contains(filter),
                            onSelected: (selected) {
                              setState(() {
                                setFilter(filter, selected);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Topics',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (String filter in topicTags)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 5.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: selectedTopicTags.contains(filter),
                            onSelected: (selected) {
                              setState(() {
                                setTopic(filter, selected);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5 / 7,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Apply"),
                onPressed: () {
                  if (!validateFilterSelection()) {
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FilteredProblems(
                                selectedTopicTags: selectedTopicTags,
                                selectedDifficultyFilter:
                                    selectedDifficultyFilter,
                                allProblems: widget.problems,
                              )));
                },
              ),
              const SizedBox(
                width: 15.0,
              ),
              ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
