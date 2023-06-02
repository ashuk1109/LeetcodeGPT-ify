import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/View/about_screen.dart';
import 'package:leetcodegptify/View/api_key_settings.dart';
import 'package:leetcodegptify/View/contests.dart';
import 'package:leetcodegptify/View/filters.dart';
import 'package:leetcodegptify/View/notes_screen.dart';

import '../Controller/leetcode_problems_controller.dart';
import '../Model/problem.dart';
import '../View/all_problems.dart';
import '../View/bookmarks.dart';
import '../View/home_screen.dart';
import '../View/level_screen.dart';
import 'common_animations.dart';

class CommonWidgetsUtility {
  static Future<Drawer> getDrawer(BuildContext context) async {
    final leetcodeController = LeetcodeAPIController();
    List<Problem> problemList =
        await leetcodeController.getAllLeetcodeProblems();

    if (problemList.length == 1 && problemList[0].questionId == "-10") {
      var cacheManager = DefaultCacheManager();
      problemList =
          await leetcodeController.fetchAndParseLeetcodeData(cacheManager);
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: const Text("LetcodeGPT-ify"),
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context, SlidePageRoute(page: const HomeScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text("All Problems"),
            onTap: () {
              Navigator.push(
                  context,
                  SlidePageRoute(
                      page: AllProblemsScreen(
                    allProblems: problemList,
                  )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.search_outlined),
            title: const Text("Search"),
            onTap: () {
              CommonUtilityMethods.showSearchDelegate(problemList, context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.filter_list),
            title: const Text("Filter"),
            onTap: () {
              Navigator.push(
                  context,
                  SlidePageRoute(
                      page: FilterScreen(
                    problems: problemList,
                  )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border_outlined),
            title: const Text("Bookmarks"),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(
                    page: Bookmarks(
                  allProblems: problemList,
                )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.align_vertical_top),
            title: const Text("Level-wise Problems"),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(
                    page: LevelScreen(
                  allProblems: problemList,
                )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text("Notes"),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(
                    page: NotesScreen(
                  allProblems: problemList,
                )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_rounded),
            title: const Text("Contests"),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const ContestScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
