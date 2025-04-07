const String _table =
    'fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF';
const List<int> _s = [11, 10, 3, 8, 4, 6];
const int _xor = 177451812;
const int _add = 8728348608;

final Map<String, int> _tr = {};

BvAvConverter() {
  for (int i = 0; i < _table.length; i++) {
    _tr[_table[i]] = i;
  }
}

/// 将 BV 号（如 BV17x411w7KC）转换为 AV 号（aid）
String bv2av(String bv) {
  if (bv.length != 12 || !bv.startsWith('BV')) {
    throw FormatException('Invalid BV format');
  }

  int r = 0;
  for (int i = 0; i < 6; i++) {
    String char = bv[_s[i]];
    int? index = _tr[char];
    if (index == null) {
      throw FormatException('Invalid character in BV string');
    }
    r += index * pow(58, i).toInt();
  }
  return ((r - _add) ^ _xor).toString();
}

/// 将 AV 号（aid）转换为 BV 号（如 BV17x411w7KC）
String av2bv(int aid) {
  int x = (aid ^ _xor) + _add;
  List<String> r = List<String>.from('BV1  4 1 7  '.split(''));

  for (int i = 0; i < 6; i++) {
    int index = (x ~/ pow(58, i).toInt()) % 58;
    r[_s[i]] = _table[index];
  }

  return r.join();
}

// 帮助函数：次方计算（Dart 没有内置整数次方）
num pow(num base, int exponent) {
  return base == 0 && exponent == 0
      ? 1
      : List.filled(exponent, base).reduce((a, b) => a * b);
}
