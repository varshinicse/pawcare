class ServiceAppointment {
  final String id;
  final String serviceTitle;
  final String serviceCategory; // "Grooming", "Veterinary", "Vaccination", "Training", "Boarding"
  final String petId;
  final String petName;
  final DateTime dateTime;
  final double price;
  final String status; // "Upcoming", "Confirmed", "Completed", "Cancelled"
  final String clinicName;
  final String notes;

  ServiceAppointment({
    required this.id,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.petId,
    required this.petName,
    required this.dateTime,
    required this.price,
    this.status = 'Upcoming',
    this.clinicName = 'PawCare Health Center',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'serviceCategory': serviceCategory,
      'petId': petId,
      'petName': petName,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
      'status': status,
      'clinicName': clinicName,
      'notes': notes,
    };
  }

  factory ServiceAppointment.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceAppointment(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      serviceTitle: map['serviceTitle'] ?? 'Pet Care Service',
      serviceCategory: map['serviceCategory'] ?? 'General',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? 'Pet',
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Upcoming',
      clinicName: map['clinicName'] ?? 'PawCare Health Center',
      notes: map['notes'] ?? '',
    );
  }

  ServiceAppointment copyWith({
    String? id,
    String? serviceTitle,
    String? serviceCategory,
    String? petId,
    String? petName,
    DateTime? dateTime,
    double? price,
    String? status,
    String? clinicName,
    String? notes,
  }) {
    return ServiceAppointment(
      id: id ?? this.id,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      status: status ?? this.status,
      clinicName: clinicName ?? this.clinicName,
      notes: notes ?? this.notes,
    );
  }
}
