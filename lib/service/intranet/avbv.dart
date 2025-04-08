const String _table =
    'fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF';
const List<int> _s = [11, 10, 3, 8, 4, 6];
const int _xor = 177451812;
const int _add = 8728348608;

final Map<String, int> _tr = {
  for (int i = 0; i < _table.length; i++) _table[i]: i
};

/// BV号 -> av号
String bv2av(String bv) {
  if (bv.length != 12 || !bv.startsWith('BV')) {
    throw ArgumentError('Invalid BV format');
  }

  int r = 0;
  for (int i = 0; i < 6; i++) {
    String c = bv[_s[i]];
    int? index = _tr[c];
    if (index == null) {
      throw ArgumentError('Invalid character in BV: $c');
    }
    r += index * _intPow(58, i);
  }

  return ((r - _add) ^ _xor).toString();
}

/// av号 -> BV号
String av2bv(String avstring) {
  final av = int.parse(avstring);
  int x = (av ^ _xor) + _add;
  List<String> result = 'BV1  4 1 7  '.split('');

  for (int i = 0; i < 6; i++) {
    int pow58 = _intPow(58, i);
    int index = (x ~/ pow58) % 58;
    result[_s[i]] = _table[index];
  }

  return result.join();
}

int _intPow(int base, int exponent) {
  int result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}

void main() {
  print(bv2av('BV17x411w7KC')); // 170001
  print(bv2av('BV1Q541167Qg')); // 455017605
  print(bv2av('BV1mK4y1C7Bz')); // 882584971

  print(av2bv('170001')); // BV17x411w7KC
  print(av2bv('455017605')); // BV1Q541167Qg
  print(av2bv('882584971')); // BV1mK4y1C7Bz
}
