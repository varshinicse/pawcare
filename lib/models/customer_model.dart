class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final List<String> registeredPetIds;
  final DateTime joinedDate;
  final String notes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.registeredPetIds,
    required this.joinedDate,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'registeredPetIds': registeredPetIds,
      'joinedDate': joinedDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map, String docId) {
    return Customer(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      name: map['name'] ?? 'Customer',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      registeredPetIds: List<String>.from(map['registeredPetIds'] ?? []),
      joinedDate: DateTime.tryParse(map['joinedDate'] ?? '') ?? DateTime.now(),
      notes: map['notes'] ?? '',
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    List<String>? registeredPetIds,
    DateTime? joinedDate,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      registeredPetIds: registeredPetIds ?? this.registeredPetIds,
      joinedDate: joinedDate ?? this.joinedDate,
      notes: notes ?? this.notes,
    );
  }
}
