int calculateReadableScore(String input) {
  int score = 0;
  final regex = RegExp(
    r'[\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af]',
  );

  for (var char in input.runes) {
    if (regex.hasMatch(String.fromCharCode(char))) {
      score += 1;
    }
  }

  return score;
}

void main() {
  String recovered = "~~ыW~~Yw~~vЕVvЕVсФUА~~uzVuzV~~UЮ";
  int score = calculateReadableScore(recovered);
  print("得分: $score");
}
