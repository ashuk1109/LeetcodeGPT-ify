import 'package:flutter/material.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/View/problem_details.dart';

class DataSearch extends SearchDelegate<String> {
  final List<Problem> problems;
  List<String> recentSearches = [];

  DataSearch({required this.problems});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> problemNames = problems.map((e) => e.title).toList();
    final results = problemNames
        .where((element) => element.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(results[index]),
          onTap: () async {
            query = results[index];
            recentSearches.add(query);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> problemNames = problems.map((e) => e.title).toList();

    final suggestions = query.isEmpty
        ? recentSearches
        : problemNames
            .where((element) =>
                element.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () async {
            query = suggestions[index];
            Problem problem = problems.firstWhere((element) =>
                element.title.toLowerCase().contains(query.toLowerCase()));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProblemDetails(
                  problem: problem,
                  allProblems: problems,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
