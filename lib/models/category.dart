class Category {
  final String name;
  final String categoryCode;
  final List<String> hashTags;

  Category(
      {required this.name, required this.categoryCode, required this.hashTags});
}

class LiarCategory {
  final String name;
  final String categoryCode;
  final List<String> words;

  LiarCategory(
      {required this.name, required this.categoryCode, required this.words});
}
