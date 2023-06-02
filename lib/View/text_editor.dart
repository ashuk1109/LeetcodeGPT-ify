import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/View/solution_screen.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/ViewModel/text_editor_viewmodel.dart';

class MyCodeEditor extends StatefulWidget {
  final String startingCode;
  final String language;
  final Problem problem;

  const MyCodeEditor(
      {super.key,
      required this.startingCode,
      required this.problem,
      required this.language});

  @override
  _MyCodeEditorState createState() => _MyCodeEditorState();
}

class _MyCodeEditorState extends State<MyCodeEditor> {
  final _viewModel = TextEditorViewModel();
  late CodeController controller;

  @override
  void initState() {
    controller = CodeController(
      text: widget.startingCode.trim(),
      language: _viewModel.getHighlightLanguageMode(widget.language),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Code Editor'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(
              child: CodeTheme(
                data: CodeThemeData(styles: atomOneDarkTheme),
                child: CodeField(
                  controller: controller,
                  maxLines: null,
                  gutterStyle: GutterStyle.none,
                ),
              ),
            ),
            const SizedBox(
              height: 25.0,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text("Save and go back"),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SolutionScreen(
                                    answer: controller.fullText,
                                    problem: widget.problem,
                                    language: widget.language,
                                  )));
                    },
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  ElevatedButton(
                    child: const Text("Redirect to leetcode"),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: controller.fullText));
                      String url =
                          "https://leetcode.com/problems/${widget.problem.titleSlug}";
                      CommonUtilityMethods.launchURL(url);
                    },
                  ),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}
