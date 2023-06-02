import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/Model/notes.dart';
import 'package:leetcodegptify/View/filtered_problem_list.dart';
import 'package:leetcodegptify/View/solution_screen.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Common/common_animations.dart';

class ProblemDetails extends StatefulWidget {
  final Problem problem;
  final List<Problem> allProblems;

  const ProblemDetails(
      {Key? key, required this.problem, required this.allProblems})
      : super(key: key);

  @override
  State<ProblemDetails> createState() => _ProblemDetailsState();
}

class _ProblemDetailsState extends State<ProblemDetails> {
  final _viewModel = ProblemsViewModel();

  late String? selectedLanguage;
  String answer = "";
  bool isLoading = false;
  List<Problem> allProblems = [];
  List<Problem> bookmarks = [];
  List<Notes> notesArray = [];
  List<String> hints = [];
  bool isBookmark = false;
  bool hasInternetConnection = true;

  @override
  void initState() {
    checkForConnectivity();
    fetchLeetcodeList();
    selectedLanguage =
        widget.problem.topicTags.contains("Database") ? "MySQL" : "Java";
    super.initState();
  }

  checkForConnectivity() async {
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection == false) {
      setState(() {
        isLoading = false;
      });
    } else {
      //fetch hints if hints weren't fetched already
      if (hints.length == 1 && hints[0] == "no internet") {
        hints = await _viewModel.fetchHints(widget.problem.titleSlug);
      }
      setState(() {});
    }
  }

  void fetchLeetcodeList() async {
    setState(() {
      isLoading = true;
    });
    bookmarks = await _viewModel.fetchBoomarks();
    notesArray = await _viewModel.fetchNotes();
    isBookmark = _viewModel.isBookmark(bookmarks, widget.problem);
    hints = await _viewModel.fetchHints(widget.problem.titleSlug);
    setState(() {
      isLoading = false;
    });
  }

  void showErrorDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error occurred"),
            content: const Text(
              "There was some error, please try again!! \n"
              "If the problem continues, contact the developer or create an issue on the github link",
              textAlign: TextAlign.justify,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ok")),
            ],
          );
        });
  }

  navigateToSolutionScreen(
      String answer, String selectedLanguage, Problem problem) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SolutionScreen(
                answer: answer,
                language: selectedLanguage,
                problem: problem,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Problem problem = widget.problem;
    allProblems = widget.allProblems;

    if (hasInternetConnection == false ||
        (hints.length == 1 && hints[0] == "no internet")) {
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
                  setState(() {});
                },
                child: const Wrap(
                  children: [Icon(Icons.refresh), Text(" Try again")],
                )),
          ],
        )),
      );
    }

    if (isLoading) {
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
          Text("Loading Problem....")
        ],
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(problem.title),
        actions: <Widget>[
          IconButton(
            icon: hints.isNotEmpty
                ? const Icon(Icons.help)
                : const Visibility(
                    visible: false,
                    child: Icon(Icons.live_help),
                  ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      "Hints",
                      style: TextStyle(fontSize: 25.0),
                    ),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: hints.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text("${index + 1}. ${hints[index]}\n");
                        },
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close")),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  Notes oldNote = notesArray.firstWhere(
                      (element) => element.questionId == problem.questionId,
                      orElse: () =>
                          Notes(questionId: '-1', title: '', note: ''));
                  var notesController = TextEditingController(
                      text: oldNote.questionId == "-1" ? "" : oldNote.note);
                  return AlertDialog(
                    title: Text(
                      "Add Note for ${problem.title}",
                      style: const TextStyle(fontSize: 15.0),
                    ),
                    content: TextFormField(
                      controller: notesController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(8.0),
                        hintText: "Enter note",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            notesController.clear();
                          },
                        ),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel")),
                      ElevatedButton(
                          onPressed: () async {
                            notesArray = await _viewModel.saveNote(notesArray,
                                oldNote, problem, notesController.text);
                            Navigator.of(context).pop();
                          },
                          child: const Text("Save")),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: bookmarks
                    .any((element) => element.questionId == problem.questionId)
                ? Icon(
                    Icons.bookmark_add,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )
                : const Icon(Icons.bookmark_add_outlined),
            onPressed: () async {
              _viewModel.updateBookmarks(bookmarks, problem);
              setState(() {});
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width / 15),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: const Text("Related Topics:"),
                    ),
                    for (String tag in problem.topicTags)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ElevatedButton(
                          child: Text(tag),
                          onPressed: () {
                            Navigator.push(
                                context,
                                SlidePageRoute(
                                    page: FilteredProblems(selectedTopicTags: [
                                  tag
                                ], selectedDifficultyFilter: const [
                                  "Easy",
                                  "Medium",
                                  "Hard"
                                ], allProblems: allProblems)));
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Html(
                            data: problem.content,
                            style: {
                              "img": Style(
                                width: Width(
                                    MediaQuery.of(context).size.width * 0.9),
                              ),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(
            height: 15,
          ),
          Flexible(
            flex: 1,
            child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(30.0),
              value: selectedLanguage,
              items: !widget.problem.topicTags.contains("Database")
                  ? <String>[
                      "Java",
                      "C++",
                      "Python",
                      "JavaScript",
                      "TypeScript"
                    ].map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                  : <String>["MySQL", "MS SQL Server", "Oracle"]
                      .map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              onChanged: (String? _selectedLanguage) {
                setState(() {
                  selectedLanguage = _selectedLanguage;
                });
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text("Ask GPT"),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      final prefs = await SharedPreferences.getInstance();
                      if (prefs.containsKey(
                          "code_${widget.problem.titleSlug}-$selectedLanguage")) {
                        answer = prefs.getString(
                                "code_${widget.problem.titleSlug}-$selectedLanguage") ??
                            "";
                      } else if (!prefs.containsKey(
                              "code_${widget.problem.titleSlug}-$selectedLanguage") ||
                          answer == "") {
                        answer = await _viewModel.getCodeForProblem(
                            widget.problem.title,
                            widget.problem.titleSlug,
                            selectedLanguage ?? "Java");
                      }

                      if (answer == "no internet") {
                        setState(() {
                          hasInternetConnection = false;
                        });
                        return;
                      } else if (answer == "There was some error") {
                        showErrorDialog();
                        setState(() {
                          isLoading = false;
                        });
                        return;
                      }

                      setState(() {
                        isLoading = false;
                      });
                      // _showAnswerDialog(context, answer);
                      navigateToSolutionScreen(
                          answer, selectedLanguage ?? "Java", problem);
                    },
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String url =
                          "https://leetcode.com/problems/${widget.problem.titleSlug}";
                      CommonUtilityMethods.launchURL(url);
                    },
                    child: const Text("Try on Leetcode"),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
