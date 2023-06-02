import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Common/common_methods.dart';
import '../ViewModel/verification_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _viewModel = VerificationViewModel();

  String? apiKey = "";
  String valueToUpdate = "";
  bool isLoading = false;
  bool hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    fetchApiKey();
  }

  checkForConnectivity() async {
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection = false) {
      isLoading = false;
    }
    setState(() {});
  }

  fetchApiKey() async {
    apiKey = await _viewModel.getSecretKey();
    setState(() {});
  }

  validateSecretKey() async {
    // TODO: move entire business-logic from View to ViewModel
    if (apiKey == valueToUpdate) {
      Fluttertoast.showToast(
          msg: _viewModel.provideDifferentKey,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (valueToUpdate.isEmpty) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: _viewModel.provideKeyToUpdate,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    await _viewModel.writeSecretKeyToSecureStorage(valueToUpdate);

    String result = await _viewModel.testSecretKey(valueToUpdate);

    if (result == "no internet") {
      // do not update api key
      await _viewModel.writeSecretKeyToSecureStorage(apiKey!);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: _viewModel.noInternet,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    } else if (result == "success") {
      //api key is valid and updated
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: _viewModel.secretKeyUpdated,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      popContextAfterUpdate();
    } else {
      // api key is not valid, hence dont update
      await _viewModel.writeSecretKeyToSecureStorage(apiKey!);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: _viewModel.provideValidSecretKey,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  popContextAfterUpdate() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitFadingCircle(
            color: Colors.grey,
            size: 50.0,
          ),
          Text(_viewModel.verifyingSecretKey),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ));
    }

    if (apiKey == null) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: Text(
            _viewModel.secretKeyError,
            style: const TextStyle(fontSize: 25.0),
          ));
    } else if (apiKey == "") {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: const Column(
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

    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: const Text("View Secret Key"),
                children: [
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 6,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              initialValue: apiKey,
                              enabled: false,
                              maxLines: null,
                            ),
                          ),
                          ElevatedButton(
                            child: const Text("Copy"),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: apiKey!));
                            },
                          )
                        ],
                      )),
                ],
              ),
              ExpansionTile(
                title: const Text("Update Secret Key"),
                children: [
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 6,
                            child: TextFormField(
                                decoration: const InputDecoration(),
                                initialValue: valueToUpdate,
                                maxLines: null,
                                onChanged: (String? apiKey) {
                                  setState(() {
                                    valueToUpdate = apiKey!;
                                  });
                                }),
                          ),
                          ElevatedButton(
                            child: const Text("Update"),
                            onPressed: () async {
                              validateSecretKey();
                            },
                          )
                        ],
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}
