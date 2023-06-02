import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/View/all_problems.dart';
import 'package:leetcodegptify/ViewModel/problems_viewmodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:leetcodegptify/Model/problem.dart';
import 'package:leetcodegptify/Model/notes.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Common/common_animations.dart';

class NotesScreen extends StatefulWidget {
  final List<Problem> allProblems;

  const NotesScreen({Key? key, required this.allProblems}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _viewModel = ProblemsViewModel();

  List<Notes> notes = [];
  bool isDownloading = false;
  bool permissionStatus = true;
  Drawer? drawer;

  @override
  void initState() {
    fetchDrawer();
    fetchLeetcodeList();
    super.initState();
  }

  fetchDrawer() async {
    drawer = await _viewModel.fetchDrawer(context);
    setState(() {});
  }

  void fetchLeetcodeList() async {
    notes = await _viewModel.fetchNotes();
    setState(() {
      // no impl required
    });
  }

  void deleteNote(int index) async {
    notes = await _viewModel.deleteNote(notes, index);
    setState(() {});
  }

  // Function to create a PDF document with a list of notes
  Future<bool> createPdf() async {
    List<Problem> problems = await _viewModel.getAllProblems();

    final pdf = pw.Document();

    bool isPermissionGranted = await Permission.manageExternalStorage.isGranted;

    //if not granted, request the permission
    if (!isPermissionGranted) {
      PermissionStatus status =
          await Permission.manageExternalStorage.request();

      if (!status.isGranted) {
        showPermisisonDeniedDialog();
        return false;
      }
    }

    int now = DateTime.now().millisecondsSinceEpoch;

    String fileName;

    if (notes.length == 1) {
      fileName = "${notes[0].title}_$now.pdf";
    } else {
      fileName = "Notes_$now.pdf";
    }

    for (Notes note in notes) {
      Problem problem = problems
          .firstWhere((element) => element.questionId == note.questionId);

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final String link =
                "https://leetcode.com/problems/${problem.titleSlug}";

            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(problem.title,
                      style: const pw.TextStyle(fontSize: 15.0)),
                  pw.SizedBox(height: 15.0),
                  pw.Row(
                    children: [
                      pw.Text("Link to Problem: "),
                      pw.UrlLink(
                        child: pw.Text(link),
                        destination: link,
                      ),
                    ],
                  ),
                  pw.Text("Difficulty: ${problem.difficulty}"),
                  pw.SizedBox(height: 15.0),
                  pw.Divider(),
                  pw.Text("Notes: "),
                  pw.Text(note.note)
                ]);
          }));
    }

    // Save the PDF document to a file
    Directory dir = Directory('/storage/emulated/0/Download/');
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return true;
  }

  showPermisisonDeniedDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text(
              "Files Access denied, can't export Notes\n"
              "Please visit the app settings and give the files access permission",
              textAlign: TextAlign.center,
            ),
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

  showPDFDownloadedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Notes downloaded to your Downloads Folder"),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    fetchLeetcodeList();

    if (drawer == null) {
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

    if (notes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Notes"),
        ),
        drawer: drawer,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Huh, seems like you haven't yet added notes for any problem \n"
                "Go to the problems page and add notes for the problems you have solved",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                child: const Text("Add Notes"),
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                        page: AllProblemsScreen(
                      allProblems: widget.allProblems,
                    )),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => isDownloading ? false : true,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Your Notes"),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_for_offline_sharp),
                onPressed: () async {
                  setState(() {
                    isDownloading = true;
                  });
                  bool downloaded = await createPdf();
                  setState(() {
                    isDownloading = false;
                  });
                  if (downloaded == false) {
                    return;
                  }

                  showPDFDownloadedSnackBar();
                },
              ),
            ],
          ),
          drawer: drawer,
          body: !isDownloading
              ? ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      title: Text(notes[index].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                          deleteNote(index);
                        },
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(notes[index].note),
                        )
                      ],
                    );
                  },
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 50.0,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text("Creating PDF, please wait ...")
                  ],
                )),
    );
  }
}
