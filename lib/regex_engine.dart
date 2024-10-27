List parseSplit(String r, int index) {
  var result = parseConcat(r, index);
  index = result[0];
  var prev = result[1];

  while (index < r.length) {
    if (r[index] == ')') {
      break;
    }
    assert(r[index] == '|', 'BUG');
    index += 1; // Move past the '|' character

    result = parseConcat(r, index);
    index = result[0];
    var node = result[1];
    prev = ['split', prev, node];
  }
  return [index, prev];
}

List parseConcat(String r, int index) {
  var prev;
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
  return [index, prev];
}

List parseNode(String r, int index) {
  if (index >= r.length) {
    throw 'Unexpected end of regex';
  }

  var character = r[index];
  index += 1;

  assert(character != '|' && character != ')', 'BUG');
  var node;

  if (character == '(') {
    var result = parseSplit(r, index);
    index = result[0];
    node = result[1];

    if (index < r.length && r[index] == ')') {
      index += 1;
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

List parsePostFix(String r, int idx, dynamic node) {
  if (idx == r.length || !'*+{'.contains(r[idx])) {
    return [idx, node];
  }

  var ch = r[idx];
  idx += 1;
  var rmin, rmax;

  if (ch == '*') {
    rmin = 0;
    rmax = double.infinity;
  } else if (ch == '+') {
    rmin = 1;
    rmax = double.infinity;
  } else {
    var result = parseInt(r, idx);
    idx = result[0];
    var i = result[1];

    if (i == null) {
      throw Exception('Expecting an integer');
    }
    rmin = rmax = i;

    if (idx < r.length && r[idx] == ',') {
      result = parseInt(r, idx + 1);
      idx = result[0];
      var j = result[1];
      rmax = j ?? double.infinity.toInt();
    }

    if (idx < r.length && r[idx] == '}') {
      idx += 1;
    } else {
      throw Exception('Unbalanced brace');
    }
  }

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
  var start = index;
  while (index < r.length && RegExp(r'[0-9]').hasMatch(r[index])) {
    index++;
  }

  if (start == index) {
    return [index, null];
  }
  var value = int.parse(r.substring(start, index));
  return [index, value];
}