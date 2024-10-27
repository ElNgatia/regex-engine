import 'package:regex_engine/regex_engine.dart' as regex_engine;

 main(List<String> arguments) {
  String regex = 'hello';
  var index, node = regex_engine.parseSplit(regex, 0);
  if(index != regex.length){
    throw 'Unexpected end of regex';
  }
  return node;
  // print('Hello world: ${regex_engine.parseSplit('hello, world', 0)}!');
}
