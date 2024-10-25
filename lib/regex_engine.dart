int calculate() {
  return 6 * 7;
}

// a|b|c
List parseSplit(String r, int index) {
  // call concatenation first
  var result = parseConcat(r, index);
  index = result[0];
  var prev = result[1];
  while (index < r.length) {
    if (r[index] == ')') {
      break;
    }
    assert(r[index] == '|', 'BUG');

    index = result[0];
    var node = result[1];
    prev = ['split', prev, node];
  }
  return [index, null];
}
// a(bc)
List parseConcat(String r, int index) {
  var prev = null;
  while (index < r.length) {
    if (r[index] == ')' || r[index] == '|') {
      break;
    }
    var result = parseNode(r, index);
    index = result[0];
    var node = result[1];
    if (prev == null) {
      prev = node;
    } else {
      prev = ['cat', prev, node];
    }
  }
  return [index, r[index]]; // Just returning the current index and character
}

List parseNode(String r, int index) {
  var character = r[index];
  index++;
  assert(!character.contains('|') && !character.contains('(') && !character.contains(')'), 'BUG');
  var result = parseSplit(r, index);
  index = result[0];
  var node = result[1];
  if (character == '(') {
    if (index < r.length && r[index] == ')') {
      index++;
    } else {
      throw 'Unmatched parenthesis';
    }
  } else if (character == '.') {
    node = 'dot';
  } else if (character.contains('*+{')) {
    throw 'Nothing to repeat.';
  } else {
    node = character;
  }
  // TODO: continue from here
  return [index, node];
}
