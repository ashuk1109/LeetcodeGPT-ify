import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("About"),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "LeetcodeGPT-ify is the ultimate combination of the power of AI and the versatility of arguably the best coding platform.\n"
                  "This project has been created to help thousands of students out there for getting better with DSA.\n"
                  "Solve any algorithmic problem from the vast library of Leetcode Problems anytime, anywhere for free, what you need is just access to the internet.\n"
                  "Stuck somewhere, ask GPT for the code.\n"
                  "Not able to understand the code? Chat with the AI Bot and get your queries solved.\n"
                  "Have finally understood the problem? Add notes to the same so you will never waste your time on the same problem again.\n"
                  "You can also export these notes in high-quality PDFs and much more.\n",
                  textAlign: TextAlign.justify,
                ),
                Text("Made with \u2764 in Flutter"),
              ],
            ),
          ),
        ));
  }
}
