import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/ai_bot_message.dart';
import 'leetcode_problems_controller.dart';

class OpenAIAPIController {
  static const storage = FlutterSecureStorage();

  final leetcodeController = LeetcodeAPIController();

  Future<String> testKey(String key) async {
    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      return "no internet";
    }

    final url = Uri.parse(
        'https://api.openai.com/v1/engines/text-davinci-003/completions');
    final apiKey = await storage.read(key: "api-key");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          "prompt": "Write a Java solution for the following problem: Two Sum.",
          "temperature": 0.7,
          "max_tokens": 1000
        }));
    if (response.statusCode == 200) {
      return "success";
    } else {
      return "failure";
    }
  }

  Future<String> getCodeForProblem(
      String problem, String titleSlug, String language) async {
    String codeSnippet =
        await leetcodeController.getCodeSnippet(titleSlug, language);

    if (codeSnippet == "no internet") {
      return codeSnippet;
    }

    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      return "no internet";
    }

    final url = Uri.parse('https://api.openai.com/v1/completions');
    final apiKey = await storage.read(key: "api-key");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt":
              "Write solution for the following leetcode problem: $problem. Use following code snippet: $codeSnippet",
          "temperature": 0,
          "max_tokens": 2000
        }));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final completions = jsonData['choices'][0]['text'].toString();

      if (completions.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("code_$titleSlug-$language", completions);
      }
      return completions;
    } else {
      return "There was some error";
    }
  }

  Future<String> getResponsefromOpenAI(List<String> messages) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final apiKey = await storage.read(key: "api-key");
    List<MessageFromAIBot> messageList = messages.map((e) {
      int idx = messages.indexOf(e);
      return MessageFromAIBot(
          role: idx % 2 == 0 ? "user" : "assistant", content: e);
    }).toList();
    var jsonMessage = messageList.map((message) => message.toJson()).toList();
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": jsonMessage,
          "temperature": 0,
          "max_tokens": 2000,
        }));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final completions = jsonData["choices"][0]["message"]["content"];
      return completions;
    } else {
      return ("There was some error");
    }
  }
}
