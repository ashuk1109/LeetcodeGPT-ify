import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/contest.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';
import 'package:timezone/timezone.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  final _viewModel = ProblemsViewModel();
  List<ContestModel> contests = [];
  bool isLoading = true;
  bool hasInternetConnection = true;
  Drawer? drawer;

  @override
  void initState() {
    checkForConnectivity();
    fetchDrawer();
    super.initState();
    fetchContests();
  }

  checkForConnectivity() async {
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection == false) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        hasInternetConnection = true;
        isLoading = true;
      });
      await fetchContests();
      setState(() {
        isLoading = false;
      });
    }
  }

  fetchDrawer() async {
    drawer = await _viewModel.fetchDrawer(context);
    setState(() {});
  }

  fetchContests() async {
    contests = await _viewModel.fetchContests();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasInternetConnection == false) {
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

    if (isLoading || drawer == null) {
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
        ],
      ));
    }

    if (contests.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Contests"),
        ),
        drawer: drawer,
        body: const Center(
            child: Text(
          "No contests found, please check after some time",
          style: TextStyle(fontSize: 25.0),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Contests"),
      ),
      drawer: drawer,
      body: ListView.builder(
          itemCount: contests.length,
          itemBuilder: (context, index) {
            final startTimeUtc = DateTime.parse(contests[index].startTime);
            final endTimeUtc = DateTime.parse(contests[index].endTime);

            final timeZone = getLocation("Asia/Kolkata");

            TZDateTime startIst = TZDateTime.from(startTimeUtc, timeZone);
            TZDateTime endIst = TZDateTime.from(endTimeUtc, timeZone);

            return GestureDetector(
                onTap: () {
                  CommonUtilityMethods.launchURL(contests[index].url);
                },
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1.0,
                          color: Theme.of(context).colorScheme.inversePrimary),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    child: Column(
                      children: [
                        Text(
                          contests[index].name,
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                            "Duration: ${double.parse(contests[index].duration) / 3600.0} hrs"),
                        Wrap(
                          children: [
                            Text(
                                "Start Time: ${DateFormat.yMMMMd().add_jm().format(startIst)}"),
                            Text(
                                "End Time: ${DateFormat.yMMMMd().add_jm().format(endIst)}"),
                          ],
                        ),
                        Text("In next 24 hrs: ${contests[index].in24Hours}"),
                      ],
                    ),
                  ),
                ));
          }),
    );
  }
}
