import 'package:regex_engine/regex_engine.dart' as regex_engine;

void main(List<String> arguments) {
// Check if a regex pattern is provided in the arguments
  if (arguments.isEmpty) {
    print('Please provide a regex pattern as an argument.');
    return;
  }

  // The first argument is the regex pattern
  String regex = arguments[0];
  var result = regex_engine.parseSplit(regex, 0);
  var index = result[0];
  var node = result[1];

  if (index != regex.length) {
    throw 'Unexpected end of regex';
  }

  print('Parsed regex tree: $node'); // Output of the parsed regex tree
}
