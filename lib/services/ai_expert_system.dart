class SymptomsDiagnosis {
  final String severity; // "LOW" | "MODERATE" | "HIGH"
  final List<String> possibleDiseases;
  final String recommendation;
  final String homeCare;
  final String prevention;

  SymptomsDiagnosis({
    required this.severity,
    required this.possibleDiseases,
    required this.recommendation,
    required this.homeCare,
    required this.prevention,
  });
}

class AiExpertSystem {
  static SymptomsDiagnosis analyzeSymptoms(String query, String species) {
    final cleanQuery = query.toLowerCase();

    if (cleanQuery.contains('vomit') || cleanQuery.contains('puk')) {
      return SymptomsDiagnosis(
        severity: 'HIGH',
        possibleDiseases: ['Gastroenteritis', 'Dietary Indiscretion', 'Parvovirus (if puppy)', 'Foreign Body Obstruction'],
        recommendation: 'Immediate veterinary consult is advised if vomiting occurs more than twice in 24 hours or contains blood.',
        homeCare: 'Fast the pet for 12 hours. Provide small amounts of water or ice chips. Introduce bland diet (boiled chicken & rice) slowly.',
        prevention: 'Avoid sudden diet shifts, keep small chewable toys away from dogs, and keep trash covered.',
      );
    }

    if (cleanQuery.contains('scratch') || cleanQuery.contains('itch') || cleanQuery.contains('flea') || cleanQuery.contains('hair loss')) {
      return SymptomsDiagnosis(
        severity: 'LOW',
        possibleDiseases: ['Flea Allergy Dermatitis (FAD)', 'Atopic Dermatitis', 'Sarcoptic Mange', 'Food Allergies'],
        recommendation: 'Schedule a vet checkup for diagnostic skin scraping. Implement monthly flea/tick preventative.',
        homeCare: 'Bathe with soothing colloidal oatmeal shampoo. Clean bedding with hypoallergenic detergents.',
        prevention: 'Apply veterinary-approved topical or chewable flea/tick preventative monthly year-round.',
      );
    }

    if (cleanQuery.contains('cough') || cleanQuery.contains('sneeze') || cleanQuery.contains('wheez')) {
      return SymptomsDiagnosis(
        severity: 'MODERATE',
        possibleDiseases: ['Kennel Cough (Infectious Tracheobronchitis)', 'Heartworm Disease', 'Feline Asthma (if cat)', 'Pneumonia'],
        recommendation: 'Consult a vet if cough persists beyond 48 hours or is accompanied by nasal discharge.',
        homeCare: 'Keep pet in a humidified environment (e.g. bathroom with hot shower running). Avoid collars, use a harness.',
        prevention: 'Administer annual DHPP + Bordetella vaccines and monthly heartworm prophylaxis.',
      );
    }

    if (cleanQuery.contains('letharg') || cleanQuery.contains('tired') || cleanQuery.contains('weak')) {
      return SymptomsDiagnosis(
        severity: 'MODERATE',
        possibleDiseases: ['Anemia', 'Tick Fever (Ehrlichiosis)', 'Dehydration', 'Systemic Infection'],
        recommendation: 'Check gum color. If gums are pale, seek emergency veterinary attention immediately.',
        homeCare: 'Ensure fresh clean water is accessible. Place bedding in a warm, quiet area away from drafts.',
        prevention: 'Keep tick prevention current and schedule routine annual blood wellness screenings.',
      );
    }

    // Default Fallback
    return SymptomsDiagnosis(
      severity: 'LOW',
      possibleDiseases: ['General Malaise', 'Mild Indigestion'],
      recommendation: 'Observe the pet for changes in appetite, urination, or defecation. Consult your vet if symptoms escalate.',
      homeCare: 'Provide a comfortable quiet resting place. Ensure fresh water is available constantly.',
      prevention: 'Maintain scheduled annual vaccinations and keep a clean sanitised living environment.',
    );
  }
}
