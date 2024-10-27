import 'package:regex_engine/regex_engine.dart' as regex_engine;

void main(List<String> arguments) {
  String regex = 'hel lo, world!(hi)';
  var result = regex_engine.parseSplit(regex, 0);
  var index = result[0];
  var node = result[1];

  if (index != regex.length) {
    throw 'Unexpected end of regex';
  }

  print(node); // Output of the parsed regex tree
}
