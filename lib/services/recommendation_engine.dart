import '../models/pet_model.dart';
import '../models/recommendation_model.dart';

/// PAWCARE AI RECOMMENDATION ENGINE
/// Architecture: Knowledge-Based Expert System (Rule Engine)
///
/// This engine evaluates pet demographics (species, breed, age in years, weight)
/// against a domain-specific knowledge base of veterinary recommendations.
/// It provides explainable, deterministic advice with explicit reasoning metadata
/// designed for academic presentation and real-world pet health guidance.
class RecommendationEngine {
  static final List<Recommendation> _knowledgeBase = [
    // --- PUPPIES / KITTENS (Age < 1) ---
    Recommendation(
      ruleId: 'rule_puppy_vax',
      species: 'dog',
      breed: 'any',
      minAge: 0.0,
      maxAge: 0.8,
      category: 'vaccination',
      suggestion: 'Schedule core DHPP & Rabies booster shots for your growing puppy.',
      reasoning: 'Puppies under 1 year require a 3-series vaccination protocol to develop maternal-antibody independent immunity.',
    ),
    Recommendation(
      ruleId: 'rule_kitten_deworm',
      species: 'cat',
      breed: 'any',
      minAge: 0.0,
      maxAge: 0.8,
      category: 'vaccination',
      suggestion: 'Administer monthly kitten deworming and FVRCP vaccination dose.',
      reasoning: 'Kittens are vulnerable to gastrointestinal parasites and respiratory viruses requiring frequent early prophylaxis.',
    ),

    // --- SENIOR PETS (Age >= 7.0 - Top Priority Wellness) ---
    Recommendation(
      ruleId: 'rule_senior_bloodwork',
      species: 'any',
      breed: 'any',
      minAge: 7.0,
      maxAge: 30.0,
      category: 'checkup',
      suggestion: 'Schedule bi-annual senior wellness screening and renal panel bloodwork.',
      reasoning: 'Pets over 7 years experience age-related metabolic shifts, requiring early detection of kidney or thyroid dysfunction.',
    ),
    Recommendation(
      ruleId: 'rule_senior_mobility',
      species: 'dog',
      breed: 'any',
      minAge: 8.0,
      maxAge: 30.0,
      category: 'diet',
      suggestion: 'Provide orthopedic bedding and glucosamine chondroitin daily treats.',
      reasoning: 'Senior canines suffer progressive articular cartilage degeneration benefiting from chondroprotective nutrients.',
    ),

    // --- GOLDEN RETRIEVER / LABRADOR (Joint & Weight management) ---
    Recommendation(
      ruleId: 'rule_retriever_joint',
      species: 'dog',
      breed: 'Golden Retriever',
      minAge: 1.0,
      maxAge: 6.9,
      category: 'grooming',
      suggestion: 'Perform bi-weekly undercoat brushing and consider omega-3 joint supplements.',
      reasoning: 'Golden Retrievers have dense double coats prone to matting and elevated genetic risk for hip dysplasia.',
    ),
    Recommendation(
      ruleId: 'rule_lab_diet',
      species: 'dog',
      breed: 'Labrador Retriever',
      minAge: 1.0,
      maxAge: 6.9,
      category: 'diet',
      suggestion: 'Strict portion control: measured double meals to prevent rapid weight gain.',
      reasoning: 'Labrador Retrievers carry a POMC gene deletion predisposing them to hyperphagia (constant hunger) and canine obesity.',
    ),

    // --- GERMAN SHEPHERD (Diet & Digestion) ---
    Recommendation(
      ruleId: 'rule_gsd_digest',
      species: 'dog',
      breed: 'German Shepherd',
      minAge: 1.0,
      maxAge: 6.9,
      category: 'diet',
      suggestion: 'Use elevated food bowls and avoid vigorous exercise 1 hour post-feeding.',
      reasoning: 'Deep-chested breeds like German Shepherds are susceptible to Gastric Dilation-Volvulus (bloat).',
    ),

    // --- POODLE & SHIH TZU (Grooming) ---
    Recommendation(
      ruleId: 'rule_poodle_grooming',
      species: 'dog',
      breed: 'Poodle',
      minAge: 0.8,
      maxAge: 6.9,
      category: 'grooming',
      suggestion: 'Schedule professional clip & ear cleaning every 4-6 weeks.',
      reasoning: 'Poodle hair grows continuously without shedding, leading to ear canal hair impaction if untrimmed.',
    ),
    Recommendation(
      ruleId: 'rule_shihtzu_eye',
      species: 'dog',
      breed: 'Shih Tzu',
      minAge: 0.8,
      maxAge: 6.9,
      category: 'checkup',
      suggestion: 'Daily eye wiping and tear stain care to prevent corneal ulceration.',
      reasoning: 'Brachycephalic ocular conformation makes Shih Tzus prone to shallow eye sockets and epiphora.',
    ),

    // --- PERSIAN & SIAMESE CATS ---
    Recommendation(
      ruleId: 'rule_persian_hairball',
      species: 'cat',
      breed: 'Persian',
      minAge: 0.8,
      maxAge: 6.9,
      category: 'grooming',
      suggestion: 'Daily stainless steel comb brushing & hairball control paste treatment.',
      reasoning: 'Longhaired Persians ingest excessive hair during grooming, resulting in trichobezoars (hairball blockages).',
    ),
    Recommendation(
      ruleId: 'rule_siamese_dental',
      species: 'cat',
      breed: 'Siamese',
      minAge: 1.0,
      maxAge: 6.9,
      category: 'checkup',
      suggestion: 'Use dental gel or kibble formulation to clean rear molars.',
      reasoning: 'Siamese cats exhibit genetic predisposition to early-onset feline odontoclastic resorptive lesions (FORL).',
    ),

    // --- GENERAL / INDIE / MIXED BREEDS ---
    Recommendation(
      ruleId: 'rule_indie_stamina',
      species: 'dog',
      breed: 'Indie / Mixed Dog',
      minAge: 1.0,
      maxAge: 6.9,
      category: 'diet',
      suggestion: 'High-protein diet balanced with 45 minutes of daily physical agility training.',
      reasoning: 'Landrace Indie dogs possess high metabolic resilience and natural endurance requiring ample physical output.',
    ),
    Recommendation(
      ruleId: 'rule_hydration_general',
      species: 'any',
      breed: 'any',
      minAge: 0.0,
      maxAge: 30.0,
      category: 'diet',
      suggestion: 'Maintain clean, fresh water fountains; clean water bowls every 24 hours.',
      reasoning: 'Optimal hydration supports renal filtration and prevents urinary tract stone crystal formation.',
    ),
  ];

  /// Core Expert System Inference Method
  static Recommendation getSuggestion(Pet pet) {
    // 1. Try exact breed match + age range match
    for (final rule in _knowledgeBase) {
      final speciesMatch = rule.species == 'any' || rule.species.toLowerCase() == pet.species.toLowerCase();
      final breedMatch = rule.breed.toLowerCase() == pet.breed.toLowerCase();
      final ageMatch = pet.age >= rule.minAge && pet.age <= rule.maxAge;

      if (speciesMatch && breedMatch && ageMatch) {
        return rule;
      }
    }

    // 2. Fallback to species + age bracket match
    for (final rule in _knowledgeBase) {
      final speciesMatch = rule.species == 'any' || rule.species.toLowerCase() == pet.species.toLowerCase();
      final ageMatch = pet.age >= rule.minAge && pet.age <= rule.maxAge;

      if (speciesMatch && ageMatch && rule.breed == 'any') {
        return rule;
      }
    }

    // 3. Fallback to general default recommendation
    return Recommendation(
      ruleId: 'rule_default_wellness',
      species: pet.species,
      breed: pet.breed,
      minAge: 0,
      maxAge: 30,
      category: 'checkup',
      suggestion: 'Schedule an annual comprehensive veterinary checkup and dental examination for ${pet.name}.',
      reasoning: 'Routine preventive exams detect silent conditions early and maintain high quality of pet life.',
    );
  }

  /// Returns full knowledge base list for inspection / seeding
  static List<Recommendation> get allRules => List.unmodifiable(_knowledgeBase);
}
