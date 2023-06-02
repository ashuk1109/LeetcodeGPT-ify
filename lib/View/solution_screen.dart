import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/chatbot_screen.dart';
import 'package:leetcodegptify/View/text_editor.dart';
import 'package:leetcodegptify/ViewModel/text_editor_viewmodel.dart';

import '../Common/common_animations.dart';

class SolutionScreen extends StatefulWidget {
  final String answer;
  final String language;
  final Problem problem;

  const SolutionScreen(
      {Key? key,
      required this.answer,
      required this.problem,
      required this.language})
      : super(key: key);

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen> {
  final _viewModel = TextEditorViewModel();

  showInfoDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text(
                "Redirect to Leetcode will take you to the Leetcode link of the problem and copy the code to clipboard so that you can test the solution!"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final String _answer = widget.answer;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Solution"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      SlidePageRoute(
                          page: MyCodeEditor(
                        startingCode: _answer,
                        problem: widget.problem,
                        language: widget.language,
                      )));
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  showInfoDialog();
                },
                icon: const Icon(Icons.info)),
          ],
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                child: SizedBox(
                  child: SingleChildScrollView(
                    child: HighlightView(
                      _answer,
                      language:
                          _viewModel.getHighlightLanguage(widget.language),
                      theme: atomOneDarkTheme,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text("Copy"),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _answer));
                        Fluttertoast.showToast(
                          msg: "Code copied to Clipboard!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    ElevatedButton(
                      child: const Text("Close"),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: const Text("Redirect to leetcode"),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _answer));
                    String url =
                        "https://leetcode.com/problems/${widget.problem.titleSlug}";
                    CommonUtilityMethods.launchURL(url);
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 6,
                child: Column(
                  children: [
                    const Text("Not satisfied, want follow-up? "),
                    TextButton(
                      child: const Text("Chat with openAI Bot"),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatBotScreen(
                                      problem: widget.problem,
                                    )));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )));
  }
}
