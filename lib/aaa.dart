int calculateGarbledScore(String input) {
  int score = 0;

  final include = r'''[
  \x00-\x1F         # 控制字符（不可见，含 \u001A）
  \u003F            # 问号 (?)
  \u00A0-\u00FF     # 拉丁补充（包含 ¿、¼、¶ 等）
  \u0370-\u03FF     # 希腊及科普特字母
  \u1A00-\u1A1F     # 布吉文等（东南亚小语种）
  \u2000-\u2BFF     # 各类符号（标点、货币、箭头、技术符号等）
  \u2200-\u22FF     # 数学运算符号
  \u2580-\u259F     # Block Elements（░ ▒ ▓ █ 等）
  \uE000-\uF8FF     # 私有区（PUA）
  \uF900-\uFAFF     # CJK 兼容汉字
  \uFFFD            # 替代字符（�）
  \u3400-\u4DBF     # CJK 扩展 A 区
]''';

  final exclude = r'[\u0020]'; // 只排除普通空格 U+0020



  final garbledPattern = RegExp(include);


  // 排除字符（例如：普通空格）
  final excludePattern = RegExp(exclude); // 只排除普通空格 U+0020

  for (var char in input.split('')) {
    // 如果是排除的字符，就跳过
    if (excludePattern.hasMatch(char)) {
      continue;
    }
    if (garbledPattern.hasMatch(char)) {
      score += 1;
    }
  }

  return score;
}

void main() {
  String recovered = "�길쐢誤곩�也썲 �阿졾ㄹ鸚⒴릲訝?";
  int score = calculateGarbledScore(recovered);
  print("乱码字符数: $score");
}
