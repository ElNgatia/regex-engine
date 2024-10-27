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
  if (index >= r.length) {
    throw 'Unexpected end of regex';
  }
  var character = r[index];
  index = index++;
  assert(!character.contains('|') && !character.contains('(') && !character.contains(')'), 'BUG');

  var node;
  if (character == '(') {
    var result = parseSplit(r, index);
    index = result[0];
    node = result[1];
    if (index < r.length && r[index] == ')') {
      index++;
    } else {
      throw 'Unmatched parenthesis';
    }
  } else if (character == '.') {
    node = 'dot';
  } else if ('*+{'.contains(character)) {
    throw 'Nothing to repeat.';
  } else {
    node = character;
  }
  var result = parsePostFix(r, index, node);
  index = result[0];
  node = result[1];

  return [index, node];
}

//  a*, a+, a{x}, a{x,}, a{x,y}
List parsePostFix(String r, int idx, dynamic node) {
  if (idx == r.length || !'*+{'.contains(r[idx])) {
    return [idx, node];
  }

  var ch = r[idx];
  idx += 1;
  int rmin, rmax;

  if (ch == '*') {
    rmin = 0;
    rmax = double.infinity.toInt();
  } else if (ch == '+') {
    rmin = 1;
    rmax = double.infinity.toInt();
  } else {
    // Parsing the first number inside the {}
    var result = parseInt(r, idx);
    idx = result[0];
    var i = result[1];

    if (i == null) {
      throw Exception('Expecting an integer');
    }
    rmin = rmax = i;

    // Check for optional second number
    if (idx < r.length && r[idx] == ',') {
      result = parseInt(r, idx + 1);
      idx = result[0];
      var j = result[1];
      rmax = j ?? double.infinity.toInt();
    }

    // Ensure the brace is closed
    if (idx < r.length && r[idx] == '}') {
      idx += 1;
    } else {
      throw Exception('Unbalanced brace');
    }
  }

  // Sanity checks
  if (rmax < rmin) {
    throw Exception('Minimum repeat count greater than maximum repeat count');
  }
  if (rmin > 1000) {
    throw Exception('Repetition number is too large');
  }

  node = ['repeat', node, rmin, rmax];
  return [idx, node];
}

List parseInt(String r, int index) {
  var save = index;
  while (index < r.length && r[index].contains('1234567890')) {
    index++;
  }
  return [int.parse(r.substring(save, index)), null];
}
