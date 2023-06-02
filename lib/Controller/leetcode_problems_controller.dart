import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:leetcodegptify/Model/problem.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/contest.dart';
import '../Model/notes.dart';

class LeetcodeAPIController {
  static const String leetcodeGraphqlEndpoint = "https://leetcode.com/graphql";
  static const String kontestEndpoint = "https://kontests.net/api/v1/leet_code";

  Future<List<Problem>> fetchProblems() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      return [
        Problem(
            questionId: "-10",
            title: "no internet",
            titleSlug: "",
            content: "",
            difficulty: "",
            isPaidOnly: false,
            topicTags: []),
      ];
    }

    final response = await http.post(
      Uri.parse(leetcodeGraphqlEndpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': '''
        query {
          allQuestions {
            questionId
            title
            titleSlug
            content
            isPaidOnly
            difficulty
            topicTags {
              name
            }
          }
        }
      '''
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> questions = data['data']['allQuestions'];
      List<Problem> problems = [];
      for (final question in questions) {
        List<String> _topicTags = [];
        for (final topicTag in question['topicTags']) {
          _topicTags.add(topicTag['name']);
        }
        final bool isPaid =
            question['isPaidOnly'].toString().toLowerCase() == "true"
                ? true
                : false;
        String _content;
        if (isPaid) {
          _content = "paid";
        } else {
          _content = question['content'];
        }
        problems.add(
          Problem(
              questionId: question['questionId'],
              title: question['title'],
              titleSlug: question['titleSlug'],
              content: _content,
              difficulty: question['difficulty'],
              isPaidOnly: isPaid,
              topicTags: _topicTags),
        );
      }
      return problems.where((e) => e.isPaidOnly == false).toList();
    } else {
      return [];
    }
  }

  Future<List<String>> fetchHints(String problemName) async {
    String url = leetcodeGraphqlEndpoint;
    String query = '''
    query questionHints(\$titleSlug: String!) {
      question(titleSlug: \$titleSlug) {
        hints
      }
    }
  ''';
    Map<String, dynamic> variables = {'titleSlug': problemName};

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'query': query,
      'variables': variables,
    };

    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      return ["no internet"];
    }

    http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['data'];
      List<dynamic> hints = data['question']['hints'];
      List<String> finalResponse = [];
      for (dynamic hint in hints) {
        hint = hint.toString();
        finalResponse.add(hint.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''));
      }
      return finalResponse;
    } else {
      //error case -> return empty response
      return [];
    }
  }

  Future<String> getCodeSnippet(String problemName, String language) async {
    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      return "no internet";
    }

    const query = r'''
    query questionEditorData($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        codeSnippets {
          lang
          langSlug
          code
        }
      }
    }
  ''';

    final variables = {
      'titleSlug': problemName,
    };

    final response = await http.post(
      Uri.parse(leetcodeGraphqlEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': query,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> javaCodeSnippet =
          data['data']['question']['codeSnippets'];
      final dynamic snippetObject = javaCodeSnippet
          .firstWhere((element) => element["lang"].toString() == language);
      return snippetObject["code"].toString();
    } else {
      return "Error";
    }
  }

  Future<void> refreshData() async {
    final prefs = await SharedPreferences.getInstance();
    var cacheManager = DefaultCacheManager();

    final lastRefresh = prefs.getInt("last-refresh") ?? 0;

    if (lastRefresh == 0) {
      // last refresh will be 0 only if prefs.getInt("last-refresh") returns null i.e. first startup of app
      // so no need to refresh data
      return;
    }

    final now = DateTime.now().microsecondsSinceEpoch;
    const oneMonthInMs = 30 * 24 * 60 * 60 * 1000;
    if (now - lastRefresh > oneMonthInMs) {
      //this means 30 days have passed, hence update the cache as well as update value for last-refresh
      await fetchAndParseLeetcodeData(cacheManager);
      await prefs.setInt("last-refresh", DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<List<Problem>> getAllLeetcodeProblems() async {
    var cacheManager = DefaultCacheManager();
    final FileInfo? fileInfo =
        await cacheManager.getFileFromCache("leetcode-data");

    if (fileInfo == null) {
      //this will be first startup
      return await fetchAndParseLeetcodeData(cacheManager);
    } else {
      // retrieve data from cache
      Uint8List cachedData = await fileInfo.file.readAsBytes();

      final jsonProblems = utf8.decode(cachedData);
      final jsonList = jsonDecode(jsonProblems);
      final List<Problem> problemList = List<Problem>.from(
          jsonList.map((problem) => Problem.fromJson(problem)));
      problemList.sort(
          (a, b) => int.parse(a.questionId).compareTo(int.parse(b.questionId)));
      return problemList;
    }
  }

  Future<List<Problem>> fetchAndParseLeetcodeData(
      DefaultCacheManager cacheManager) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Problem> problemList = await fetchProblems();

    if (problemList.length <= 1) {
      return problemList;
    }

    problemList.sort(
        (a, b) => int.parse(a.questionId).compareTo(int.parse(b.questionId)));

    //set problem list to cache
    var jsonProblems =
        jsonEncode(problemList.map((problem) => problem.toJson()).toList());
    var dataToCache = Uint8List.fromList(utf8.encode(jsonProblems));
    await cacheManager.putFile("leetcode-data", dataToCache);

    //check for last-refresh
    final lastRefresh = prefs.getInt("last-refresh") ?? 0;
    if (lastRefresh == 0) {
      //this means first call, here we want to update last-refresh
      //if last-refresh already exists, do not overwrite it, and it should be updated only once 30 days have passed
      //handle this overwrite after 30 days in parent method -> refreshData()
      await prefs.setInt("last-refresh", DateTime.now().millisecondsSinceEpoch);
    }
    return problemList;
  }

  Future<List<Problem>> fetchAndParseBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonBookmarks = prefs.getString("bookmarks");

    if (jsonBookmarks == null) {
      // this means first startup
      await prefs.setString("bookmarks", jsonEncode(<Problem>[]));
      return <Problem>[];
    }

    // this means bookmarks already exist -> so decode and return
    final List<dynamic> jsonList = jsonDecode(jsonBookmarks);
    final List<Problem> bookmarks =
        jsonList.map((e) => Problem.fromJson(e)).toList();
    return bookmarks;
  }

  void updateBookmarks(List<Problem> bookmarks, Problem problem) async {
    if (bookmarks.any((element) => element.questionId == problem.questionId)) {
      Problem problemToRemove = bookmarks
          .firstWhere((element) => element.questionId == problem.questionId);
      bookmarks.remove(problemToRemove);
    } else {
      bookmarks.add(problem);
    }
    String jsonBookmarks = jsonEncode(<Problem>[]);
    if (bookmarks.isNotEmpty) {
      jsonBookmarks = jsonEncode(bookmarks.map((e) => e.toJson()).toList());
    }
    // update shared prefs
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setString("bookmarks", jsonBookmarks));
  }

  Future<List<Notes>> fetchAndParseNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonNotes = prefs.getString("notes");

    if (jsonNotes == null) {
      await prefs.setString("notes", jsonEncode(<Notes>[]));
      return <Notes>[];
    }

    // this means notes already exist -> so decode and return
    final List<dynamic> jsonList = jsonDecode(jsonNotes);
    final List<Notes> notes = jsonList.map((e) => Notes.fromJson(e)).toList();
    return notes;
  }

  Future<List<ContestModel>> fetchAndParseContests() async {
    final response = await http.get(Uri.parse(kontestEndpoint));

    if (response.statusCode == 200) {
      final List<dynamic> contestJson = json.decode(response.body);
      final List<ContestModel> contestList =
          contestJson.map((e) => ContestModel.fromJson(e)).toList();
      return contestList;
    } else {
      return [];
    }
  }
}
