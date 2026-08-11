class Recommendation {
  final String ruleId;
  final String species;
  final String breed;
  final double minAge;
  final double maxAge;
  final String suggestion;
  final String category; // "vaccination", "grooming", "diet", "checkup"
  final String reasoning;

  Recommendation({
    required this.ruleId,
    required this.species,
    required this.breed,
    required this.minAge,
    required this.maxAge,
    required this.suggestion,
    required this.category,
    required this.reasoning,
  });

  Map<String, dynamic> toMap() {
    return {
      'ruleId': ruleId,
      'species': species,
      'breed': breed,
      'minAge': minAge,
      'maxAge': maxAge,
      'suggestion': suggestion,
      'category': category,
      'reasoning': reasoning,
    };
  }

  factory Recommendation.fromMap(Map<String, dynamic> map, String id) {
    return Recommendation(
      ruleId: id.isNotEmpty ? id : (map['ruleId'] ?? ''),
      species: map['species'] ?? 'any',
      breed: map['breed'] ?? 'any',
      minAge: (map['minAge'] as num?)?.toDouble() ?? 0.0,
      maxAge: (map['maxAge'] as num?)?.toDouble() ?? 30.0,
      suggestion: map['suggestion'] ?? 'Keep your pet hydrated and active!',
      category: map['category'] ?? 'diet',
      reasoning: map['reasoning'] ?? 'General pet wellness guidelines.',
    );
  }
}
