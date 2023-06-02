import 'package:highlight/highlight.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/typescript.dart';

class TextEditorViewModel {
  String getHighlightLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'java':
        return 'java';
      case 'c++':
        return 'cpp';
      case 'python':
        return 'python';
      case 'javascript':
        return 'javascript';
      case 'typescript':
        return 'typescript';
      default:
        return 'java';
    }
  }

  Mode getHighlightLanguageMode(String input) {
    switch (input) {
      case 'Java':
        return java;
      case 'JavaScript':
        return javascript;
      case 'C++':
        return cpp;
      case 'Python':
        return python;
      case 'TypeScript':
        return typescript;
      default:
        return java;
    }
  }
}
