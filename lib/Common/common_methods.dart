import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/problem.dart';
import '../View/search_delegate.dart';

class CommonUtilityMethods {
  static Color getColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case "easy":
        return Colors.green;
      case "medium":
        return Colors.orange;
      case "hard":
        return Colors.red;
    }

    return Colors.grey;
  }

  static Future<bool> checkForConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool hasInternetConnection = true;
    if (connectivityResult == ConnectivityResult.none) {
      hasInternetConnection = false;
    }

    return hasInternetConnection;
  }

  static launchURL(String url) async {
    checkForConnectivity();

    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  static showSearchDelegate(List<Problem> problemList, BuildContext context) {
    List<Problem> problemsToSearch = problemList;
    problemsToSearch
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    showSearch(
        context: context, delegate: DataSearch(problems: problemsToSearch));
  }
}
