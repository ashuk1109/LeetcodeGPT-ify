import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leetcodegptify/ViewModel/verification_viewmodel.dart';

import '../Common/common_animations.dart';
import 'home_screen.dart';

/// This file holds the complete logic for the prerequisites required for the app
/// viz an open ai account and a valid api key for the same i.e. the complete verification logic
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const storage = FlutterSecureStorage();

class _MyHomePageState extends State<MyHomePage> {
  final _verificationViewModel = VerificationViewModel();

  bool isLoading = false;
  bool isLastPage = false;
  bool hasInternetConnection = true;
  String _apiKey = "";
  int carouselIndex = 0;

  @override
  void initState() {
    //check for internet access first
    checkForConnectivity();
    super.initState();
  }

  checkForConnectivity() async {
    hasInternetConnection = await _verificationViewModel.checkForConnectivity();
    setState(() {});
  }

  verifySecretKey() async {
    //TODO: move this logic to viewmodel
    await _verificationViewModel.writeSecretKeyToSecureStorage(_apiKey);

    if (_apiKey.isEmpty) {
      await Fluttertoast.showToast(
        msg: _verificationViewModel.provideSecretKey,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String res = await _verificationViewModel.testSecretKey(_apiKey);

    if (res == "no internet") {
      setState(() {
        isLoading = false;
        hasInternetConnection = false;
      });
      await _verificationViewModel.deleteSecretKey();
      // do not check for validation
      return;
    } else if (res == "success") {
      await _verificationViewModel.updateVerificationStatus();
      Fluttertoast.showToast(
          msg: _verificationViewModel.secretKeyVerified,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      launchHomeScreen();
    } else {
      isLoading = false;
      setState(() {
        carouselIndex = 2;
      });
      Fluttertoast.showToast(
          msg: _verificationViewModel.provideValidSecretKey,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }
  }

  launchHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        HomeScreenZoomInPageRoute(page: const HomeScreen()),
        (Route<dynamic> route) => false);
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
                },
                child: const Wrap(
                  children: [Icon(Icons.refresh), Text(" Try again")],
                )),
          ],
        )),
      );
    }

    if (isLoading) {
      return Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitFadingCircle(
            color: Colors.grey,
            size: 50.0,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(_verificationViewModel.verifyingSecretKey)
        ],
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("LeetcodeGPT-ify"),
        ),
        body: Center(
          child: Column(
            children: [
              const Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Get Started!',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Center(
                  child: CarouselSlider(
                    items: [
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Text(
                                    "Visit OpenAI Website and create an account if not already created.",
                                    textAlign: TextAlign.center,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        _verificationViewModel.launchURL(
                                            _verificationViewModel.openAIURL);
                                      },
                                      child: const Text("Visit site")),
                                  const SizedBox(
                                    height: 100.0,
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight / 2,
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(Icons.circle_rounded, size: 5.0),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Icon(Icons.circle_outlined, size: 5.0),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Icon(Icons.circle_outlined, size: 5.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "From the account settings generate a secret key. \n"
                                    "Click on Create secret key, once created, copy the same to the clipboard",
                                    textAlign: TextAlign.center,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        _verificationViewModel.launchURL(
                                            _verificationViewModel
                                                .secretKeyURL);
                                      },
                                      child: Text(_verificationViewModel
                                          .generateSecretKey)),
                                  SizedBox(
                                    height: constraints.maxHeight / 1.75,
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(Icons.circle_outlined, size: 5.0),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Icon(Icons.circle_rounded, size: 5.0),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Icon(Icons.circle_outlined, size: 5.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: _verificationViewModel
                                          .pasteYourSecretKey,
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return _verificationViewModel
                                            .provideSecretKey;
                                      }
                                      return null;
                                    },
                                    initialValue: _apiKey,
                                    onChanged: (String? apiKey) {
                                      setState(() {
                                        _apiKey = apiKey!;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 100.0,
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight / 2,
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(Icons.circle_outlined, size: 5.0),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Icon(Icons.circle_outlined, size: 5.0),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Icon(Icons.circle_rounded, size: 5.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.85,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        reverse: false,
                        enableInfiniteScroll: false,
                        viewportFraction: 0.9,
                        enlargeFactor: 1.0,
                        initialPage: carouselIndex,
                        onPageChanged: (index, reason) {
                          if (index == 2) {
                            isLastPage = true;
                          }
                          setState(() {
                            carouselIndex = index;
                          });
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Visibility(
          visible: isLastPage,
          child: FloatingActionButton(
            onPressed: () {
              verifySecretKey();
            },
            child: const Icon(
              Icons.arrow_right_rounded,
              size: 50,
            ),
          ),
        ));
  }
}
