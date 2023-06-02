import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/openai_controller.dart';

class ChatbotViewModel {
  static final openAIController = OpenAIAPIController();
  final String errorMessage = "There was some error";
  final String firstPrompt =
      "You are a leetcode assistant ready to help the user with any leetcode problem queries. Please send a super short intro message asking user what help he needs with";

  Future<List<String>> fetchMessagesfromSharedPrefs(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("chatbot_$questionId")) {
      return (prefs.getStringList("chatbot_$questionId")) ?? [];
    }

    return [];
  }

  Future<String> getResponseFromAI(List<String> messages) async {
    return await openAIController.getResponsefromOpenAI(messages);
  }

  deleteChatHistory(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("chatbot_$questionId")) {
      prefs.remove("chatbot_$questionId");
    }
  }
}
