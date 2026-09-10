import 'package:flutter/material.dart';

class ServiceItem {
  final String id;
  final String title;
  final String category;
  final double price;
  final int durationMinutes;
  final double rating;
  final int reviewsCount;
  final String description;
  final List<String> includedFeatures;
  final IconData icon;
  final String tag;
  final String? imageAsset;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.includedFeatures,
    required this.icon,
    this.tag = 'Popular',
    this.imageAsset,
  });

  static const List<ServiceItem> defaultCatalog = [
    ServiceItem(
      id: 'srv_grooming_full',
      title: 'Full Spa Grooming & Hydro-Bath',
      category: 'Grooming',
      price: 1299.0,
      durationMinutes: 75,
      rating: 4.9,
      reviewsCount: 142,
      tag: 'Best Seller',
      imageAsset: 'assets/images/pet_spa_grooming.jpg',
      description:
          'A complete luxury grooming experience including therapeutic warm bubble bath, deep coat conditioning, paw pad sanitization, nail trimming, gentle ear cleansing, and scented finishing spritz.',
      includedFeatures: [
        'Warm organic herb hydro-bath',
        'Deep fur de-shedding & blow dry',
        'Nail trimming & paw balm massage',
        'Ear cleaning & oral hygiene spray',
        'Sanitary trim & style sculpting',
      ],
      icon: Icons.shower_rounded,
    ),
    ServiceItem(
      id: 'srv_vet_consult',
      title: 'Comprehensive Vet Wellness Checkup',
      category: 'Veterinary',
      price: 650.0,
      durationMinutes: 30,
      rating: 4.95,
      reviewsCount: 230,
      tag: 'Essential',
      imageAsset: 'assets/images/vet_clinical_service.jpg',
      description:
          'Detailed physical consultation with certified veterinary doctors. Includes cardiovascular, joint, dermatological, and dental examination along with tailored dietary advice.',
      includedFeatures: [
        'Complete nose-to-tail physical exam',
        'Heartbeat & respiratory rate assessment',
        'Dermatology & coat inspection',
        'Weight & body condition scoring',
        'Digital prescription & clinical notes',
      ],
      icon: Icons.medical_services_rounded,
    ),
    ServiceItem(
      id: 'srv_vax_core',
      title: 'Core Booster Vaccination (DHPP/Rabies)',
      category: 'Vaccination',
      price: 850.0,
      imageAsset: 'assets/images/vet_clinical_service.jpg',
      durationMinutes: 20,
      rating: 4.88,
      reviewsCount: 98,
      tag: 'Preventive',
      description:
          'Administered by certified veterinarians with cold-chain verified vaccines. Protects your pet against distemper, hepatitis, parvovirus, parainfluenza, and rabies.',
      includedFeatures: [
        'Pre-vaccine vitals evaluation',
        'Cold-chain verified core vaccine',
        'Deworming consultation',
        'Vaccination passport stamping',
        'Post-vaccine observation support',
      ],
      icon: Icons.vaccines_rounded,
    ),
    ServiceItem(
      id: 'srv_dog_walk',
      title: 'Active Adventure Walk & Exercise (45m)',
      category: 'Walking',
      price: 349.0,
      durationMinutes: 45,
      rating: 4.85,
      reviewsCount: 180,
      tag: 'Daily Care',
      description:
          'Energetic, GPS-tracked neighborhood walk by certified pet handlers. Keeps your pet active, stimulated, and happy with potty breaks and fresh water hydration.',
      includedFeatures: [
        '45 minutes active outdoor exercise',
        'Live GPS route tracking',
        'Hydration & post-walk paw wipe',
        'Photo updates & walk report card',
        'Waste bag disposal included',
      ],
      icon: Icons.directions_walk_rounded,
    ),
    ServiceItem(
      id: 'srv_daycare',
      title: 'Canopy Daycare & Social Play Session',
      category: 'Daycare',
      price: 799.0,
      durationMinutes: 240,
      rating: 4.92,
      reviewsCount: 67,
      tag: 'Play & Social',
      description:
          'Half-day supervised social cage-free play in our temperature-controlled indoor play zones. Includes agility obstacles, nap lounges, and interactive brain games.',
      includedFeatures: [
        'Cage-free supervised play area',
        'Agility & puzzle playtime',
        'Quiet nap time with soothing music',
        'Snack & hydration stations',
        'Live webcam check-in access',
      ],
      icon: Icons.cottage_rounded,
    ),
    ServiceItem(
      id: 'srv_dental_care',
      title: 'Ultrasonic Dental Scale & Polish',
      category: 'Veterinary',
      price: 1450.0,
      durationMinutes: 60,
      rating: 4.89,
      reviewsCount: 45,
      tag: 'Specialized',
      description:
          'Professional dental prophylaxis to eliminate plaque, tartar build-up, and bad breath while preventing periodontal disease.',
      includedFeatures: [
        'Oral cavity examination',
        'Ultrasonic scaling of calculus',
        'Subgingival plaque removal',
        'Fluoride enamel polishing',
        'Home dental care guidance',
      ],
      icon: Icons.health_and_safety_rounded,
    ),
  ];
}
