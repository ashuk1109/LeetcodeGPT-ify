import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:leetcodegptify/Model/contest.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/common_widgets.dart';
import '../Controller/leetcode_problems_controller.dart';
import '../Controller/openai_controller.dart';
import '../Model/notes.dart';

class ProblemsViewModel {
  static final leetcodeController = LeetcodeAPIController();
  static final openAIController = OpenAIAPIController();
  final List<Color> colorList = [Colors.green, Colors.orange, Colors.red];
  static Problem dummyProblem = Problem(
      questionId: "-1",
      title: "",
      titleSlug: "",
      content: "",
      difficulty: "",
      isPaidOnly: false,
      topicTags: []);

  Problem getProblemOfTheDay(List<Problem> mediumProblemList) {
    return Problem.generateRandom(mediumProblemList);
  }

  List<Problem> getProblemList(List<Problem> allProblems, String difficulty) {
    return allProblems
        .where((element) =>
            element.difficulty == difficulty && element.isPaidOnly == false)
        .toList();
  }

  Future<List<Problem>> getAllProblems() async {
    return await leetcodeController.getAllLeetcodeProblems();
  }

  Future<List<Problem>> fetchAllProblemsFromAPI() async {
    final cacheManager = DefaultCacheManager();
    return await leetcodeController.fetchAndParseLeetcodeData(cacheManager);
  }

  Future<Drawer> fetchDrawer(BuildContext context) async {
    return await CommonWidgetsUtility.getDrawer(context);
  }

  Future<List<Problem>> fetchBoomarks() async {
    return await leetcodeController.fetchAndParseBookmarks();
  }

  void updateBookmarks(List<Problem> bookmarks, Problem problem) async {
    leetcodeController.updateBookmarks(bookmarks, problem);
  }

  bool isBookmark(List<Problem> bookmarks, Problem problem) {
    return bookmarks.any((element) => element.questionId == problem.questionId);
  }

  Future<String> getCodeForProblem(
      String problem, String titleSlug, String language) async {
    return await openAIController.getCodeForProblem(
        problem, titleSlug, language);
  }

  List<Problem> filterProblems(List<Problem> allProblems,
      List<String> selectedDifficultyFilter, List<String> selectedTopicTags) {
    return allProblems.where((problem) {
      //check if problem difficulty is selected
      if (!selectedDifficultyFilter.contains(problem.difficulty)) {
        return false;
      }

      for (String topic in problem.topicTags) {
        if (selectedTopicTags.contains(topic)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Future<List<Notes>> fetchNotes() async {
    return await leetcodeController.fetchAndParseNotes();
  }

  Future<List<Notes>> deleteNote(List<Notes> notes, int index) async {
    notes.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("notes", jsonEncode(notes));

    return notes;
  }

  Future<List<String>> fetchHints(String titleSlug) async {
    return await leetcodeController.fetchHints(titleSlug);
  }

  Future<List<Notes>> saveNote(List<Notes> notesArray, Notes oldNote,
      Problem problem, String notes) async {
    Notes newNote = Notes(
        questionId: problem.questionId, title: problem.title, note: notes);
    if (oldNote.questionId != "-1") {
      // which means note already exists - hence we overwrite
      notesArray.remove(oldNote);
    }
    notesArray.add(newNote);

    String jsonNotes = jsonEncode(notesArray.map((e) => e.toJson()).toList());
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setString("notes", jsonNotes));

    return notesArray;
  }

  Future<List<ContestModel>> fetchContests() async {
    return await leetcodeController.fetchAndParseContests();
  }
}
