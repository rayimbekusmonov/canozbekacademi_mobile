class WordModel {
  final String tr;
  final String uz;
  final String? example;

  WordModel({required this.tr, required this.uz, this.example});

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      tr: json['tr'] ?? '',
      uz: json['uz'] ?? '',
      example: json['example'],
    );
  }
}

class UnitModel {
  final String level;
  final int unitNo;
  final String unitName;
  final List<WordModel> words;

  UnitModel({
    required this.level,
    required this.unitNo,
    required this.unitName,
    required this.words,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      level: json['level'],
      unitNo: json['unit_no'],
      unitName: json['unit_name'],
      words: (json['words'] as List)
          .map((w) => WordModel.fromJson(w))
          .toList(),
    );
  }
}