class NutritionReport {
  final double dailyCalories;
  final double mealQuantityGrams;
  final int mealFrequency;
  final double waterIntakeMl;
  final String advice;
  final List<String> foodsToAvoid;
  final List<String> recommendedFoods;

  NutritionReport({
    required this.dailyCalories,
    required this.mealQuantityGrams,
    required this.mealFrequency,
    required this.waterIntakeMl,
    required this.advice,
    required this.foodsToAvoid,
    required this.recommendedFoods,
  });
}

class AiNutritionEngine {
  static NutritionReport calculateReport({
    required String species,
    required double ageYears,
    required double weightKg,
    required String activityLevel, // "low" | "moderate" | "high"
    required List<String> medicalConditions,
  }) {
    // 1. Calculate Basal Energy Requirement (RER)
    // Formula: RER = 70 * (weightKg)^0.75
    final double rer = 70 * (weightKg > 0 ? weightKg : 5.0);

    // 2. Adjust for Activity & Life Stage (DER)
    double multiplier = 1.6;
    if (species.toLowerCase() == 'cat') {
      multiplier = 1.2;
    }

    if (ageYears < 1.0) {
      multiplier *= 2.0; // Puppies/Kittens need double
    } else if (ageYears > 8.0) {
      multiplier *= 0.8; // Seniors need less
    }

    if (activityLevel.toLowerCase() == 'low') {
      multiplier *= 0.9;
    } else if (activityLevel.toLowerCase() == 'high') {
      multiplier *= 1.35;
    }

    final double dailyCalories = rer * multiplier;

    // 3. Portion Calculation
    // Assuming standard premium dry food has 3.5 kcal/gram
    final double mealQuantityGrams = dailyCalories / 3.5;
    final int frequency = ageYears < 0.6 ? 3 : 2;

    // 4. Water Intake Recommendation
    // Standard water requirement: ~60ml per kg of body weight
    final double waterIntakeMl = weightKg * 60;

    // 5. Medical-specific adjustments
    String advice = 'Maintain a consistent feeding schedule and measure portions precisely.';
    List<String> foodsToAvoid = ['Chocolate', 'Onions & Garlic', 'Grapes & Raisins', 'Caffeine', 'Xylitol sweetener'];
    List<String> recommendedFoods = ['Deboned chicken breast', 'Brown rice', 'Sweet potatoes', 'Salmon oil (Omega-3)'];

    if (medicalConditions.contains('Sensitive Stomach')) {
      advice = 'Incorporate easily digestible single-protein recipes. Avoid grain mixers.';
      recommendedFoods = ['Pumpkin puree', 'Boiled turkey', 'Probiotic kibble topper'];
      foodsToAvoid.addAll(['Dairy products', 'High fat table scraps']);
    }

    if (medicalConditions.contains('Obesity') || weightKg > 35.0) {
      advice = 'Implement high-fiber weight control kibble to promote satiety. Reduce portions by 10%.';
      recommendedFoods = ['Green beans (low calorie snack)', 'Lean fish', 'Fiber-enriched kibble'];
      foodsToAvoid.addAll(['Cheesy treats', 'Peanut butter treats']);
    }

    return NutritionReport(
      dailyCalories: double.parse(dailyCalories.toStringAsFixed(1)),
      mealQuantityGrams: double.parse(mealQuantityGrams.toStringAsFixed(0)),
      mealFrequency: frequency,
      waterIntakeMl: double.parse(waterIntakeMl.toStringAsFixed(0)),
      advice: advice,
      foodsToAvoid: foodsToAvoid,
      recommendedFoods: recommendedFoods,
    );
  }
}
