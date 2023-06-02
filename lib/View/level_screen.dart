import 'package:flutter/material.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/problem_details.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';

import '../Common/common_methods.dart';

class LevelScreen extends StatefulWidget {
  final List<Problem> allProblems;

  const LevelScreen({Key? key, required this.allProblems}) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final _viewModel = ProblemsViewModel();
  List<Problem> easy = [];
  List<Problem> medium = [];
  List<Problem> hard = [];
  Drawer? drawer;

  @override
  void initState() {
    fetchDrawer();
    fetchAllProblemTopic();
    super.initState();
  }

  fetchDrawer() async {
    drawer = await _viewModel.fetchDrawer(context);
    setState(() {});
  }

  fetchAllProblemTopic() async {
    List<Problem> allProblems = widget.allProblems;
    medium = allProblems
        .where((element) =>
            element.difficulty == "Medium" && element.isPaidOnly == false)
        .toList();
    easy = allProblems
        .where((element) =>
            element.difficulty == "Easy" && element.isPaidOnly == false)
        .toList();
    hard = allProblems
        .where((element) =>
            element.difficulty == "Hard" && element.isPaidOnly == false)
        .toList();

    setState(() {});
  }

  Widget getTileForProblem(Problem _problem, int index) {
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
                  color: CommonUtilityMethods.getColor(_problem.difficulty),
                ),
              ),
            )
          ],
        ),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemDetails(
                problem: _problem,
                allProblems: widget.allProblems,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Level-wise Problems"),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Easy",
              ),
              Tab(
                text: "Medium",
              ),
              Tab(
                text: "Hard",
              ),
            ],
          ),
        ),
        drawer: drawer,
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: easy.length,
              itemBuilder: (context, index) {
                Problem _problem = easy[index];
                return getTileForProblem(_problem, index);
              },
            ),
            ListView.builder(
              itemCount: medium.length,
              itemBuilder: (context, index) {
                Problem _problem = medium[index];
                return getTileForProblem(_problem, index);
              },
            ),
            ListView.builder(
              itemCount: hard.length,
              itemBuilder: (context, index) {
                Problem _problem = hard[index];
                return getTileForProblem(_problem, index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
