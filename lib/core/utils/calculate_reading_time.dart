int calculateReadingTime(String text) {
  final words = text.split(RegExp(r'\s+'));
  final wordCount = words.length;
  final readingTime = (wordCount / 200).ceil();
  return readingTime;
}