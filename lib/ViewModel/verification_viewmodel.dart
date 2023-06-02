import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leetcodegptify/Controller/openai_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationViewModel {
  final String verifyingSecretKey = "Verifying your secret key, please wait!";
  final String pasteYourSecretKey = "Paste your secret key to get started.";
  final String generateSecretKey = "Generate secret key.";
  final String genratingSecretKey =
      "From the account settings generate a secret key.";
  final String provideSecretKey = "Please provide your secret key.";
  final String provideValidSecretKey = "Please provide a valid secret key.";
  final String provideDifferentKey = "Please provide a different key";
  final String copyToClipBoard = "Copy";
  final String closeWindow = "Close";
  final String secretKeyVerified = "Secret key verified successfully!!";
  final String provideKeyToUpdate = "Please provide a Secret Key to update";
  final String secretKeyUpdated = "Secret key updated successfully";
  final String secretKeyError =
      "There was a problem :(,\n please try again later";
  final String noInternet =
      "No internet connection, please check your connection and try again";
  final String openAIURL = "https://chat.openai.com/auth/login";
  final String secretKeyURL = "https://platform.openai.com/account/api-keys";

  static const storage = FlutterSecureStorage();
  static final openAIController = OpenAIAPIController();

  Future<bool> checkForConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool hasInternetConnection = true;
    if (connectivityResult == ConnectivityResult.none) {
      hasInternetConnection = false;
    }

    return hasInternetConnection;
  }

  launchURL(String url) async {
    checkForConnectivity();

    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  writeSecretKeyToSecureStorage(String apiKey) async {
    await storage.write(key: "api-key", value: apiKey);
  }

  updateVerificationStatus() async {
    await storage.write(key: "isVerified", value: 'true');
  }

  deleteSecretKey() async {
    await storage.delete(key: "api-key");
  }

  Future<String> testSecretKey(String apiKey) async {
    return await openAIController.testKey(apiKey);
  }

  Future<String?> getSecretKey() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: "api-key");
  }
}
