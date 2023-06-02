import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leetcodegptify/Common/common_animations.dart';
import 'package:leetcodegptify/Common/common_methods.dart';
import 'package:leetcodegptify/Model/problem.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ViewModel/chatbot_viewmodel.dart';

class ChatBotScreen extends StatefulWidget {
  final Problem problem;

  const ChatBotScreen({Key? key, required this.problem}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final _viewModel = ChatbotViewModel();
  final _textController = TextEditingController();
  List<String> _messages = [];
  bool isLoading = false;
  bool hasInternetConnection = true;

  @override
  void initState() {
    checkForConnectivity();
    _sendFirstMessage();
    super.initState();
  }

  checkForConnectivity() async {
    hasInternetConnection = await CommonUtilityMethods.checkForConnectivity();
    if (hasInternetConnection == false) {
      isLoading = false;
    }
    setState(() {});
  }

  Future<void> _sendFirstMessage() async {
    setState(() {
      isLoading = true;
    });

    _messages = await _viewModel
        .fetchMessagesfromSharedPrefs(widget.problem.questionId);

    if (_messages.isNotEmpty) {
      //means user has already chatted for this question
      setState(() {
        isLoading = false;
      });
      return;
    }

    _messages.add("${_viewModel.firstPrompt} ${widget.problem.title}");
    String response = await _viewModel.getResponseFromAI(_messages);

    setState(() {
      isLoading = false;
      _messages.add(response);
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      _textController.clear();
      _messages.add(message);

      String response = await _viewModel.getResponseFromAI(_messages);

      if (response == _viewModel.errorMessage) {
        _messages.add("");
        showErrorDialog();
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        isLoading = false;
        _messages.add(response);
      });
    }
  }

  showErrorDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error occurred"),
            content: const Text(
              "Looks like the openAI servers are busy right now, please try again later",
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
            ],
          );
        });
  }

  removeChatHistory() async {
    _viewModel.deleteChatHistory(widget.problem.questionId);
  }

  showDeleteDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text("Are you sure you want to delete this chat?"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () {
                  removeChatHistory();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      SlidePageRoute(
                          page: ChatBotScreen(
                        problem: widget.problem,
                      )));
                },
                child: const Text("Yes"),
              )
            ],
          );
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

    return WillPopScope(
      onWillPop: () async {
        var prefs = await SharedPreferences.getInstance();
        prefs.setStringList("chatbot_${widget.problem.questionId}", _messages);

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OpenAI Chat Bot'),
          actions: [
            IconButton(
              onPressed: () {
                showDeleteDialog();
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index].replaceAll("```", "").trim();
                  final isUser = index % 2 == 0;
                  if (index == 0 || (message.isEmpty && !isUser)) {
                    return Visibility(
                      visible: false,
                      child: ChatBubble(message: message, isUser: isUser),
                    );
                  }
                  return ChatBubble(message: message, isUser: isUser);
                },
              ),
            ),
            isLoading
                ? Container(
                    alignment: Alignment.topCenter,
                    child: SpinKitWave(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: 'Type a prompt',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            _sendMessage(_textController.text);
                          },
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = isUser
        ? colorScheme.inversePrimary
        : (Theme.of(context).brightness == Brightness.light
            ? colorScheme.secondaryContainer
            : colorScheme.onSecondary);

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(30),
              topRight: const Radius.circular(30),
              bottomLeft:
                  isUser ? const Radius.circular(30) : const Radius.circular(0),
              bottomRight:
                  isUser ? const Radius.circular(0) : const Radius.circular(30),
            ),
          ),
          child: SelectableText(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
