import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';

class CustomerProvider with ChangeNotifier {
  static const String _storageKey = 'pawcare_customers_data';
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final List decoded = jsonDecode(data);
        _customers = decoded.map((e) => Customer.fromMap(Map<String, dynamic>.from(e), '')).toList();
      } else {
        _customers = [
          Customer(
            id: 'cust_1',
            name: 'Varshini Parani',
            phone: '+91 98765 43210',
            email: 'varshini@pawcare.app',
            address: '42 Orchid Residency, Indiranagar, Bangalore',
            registeredPetIds: ['pet_bruno_1', 'pet_luna_2'],
            joinedDate: DateTime.now().subtract(const Duration(days: 120)),
            notes: 'Prefers morning appointments. Bruno has sensitive stomach.',
          ),
          Customer(
            id: 'cust_2',
            name: 'Rahul Sharma',
            phone: '+91 98450 12345',
            email: 'rahul.sharma@gmail.com',
            address: '15 Palm Meadows, Whitefield, Bangalore',
            registeredPetIds: [],
            joinedDate: DateTime.now().subtract(const Duration(days: 45)),
            notes: 'Interested in adoption and puppy training sessions.',
          ),
          Customer(
            id: 'cust_3',
            name: 'Ananya Deshmukh',
            phone: '+91 97312 98765',
            email: 'ananya.d@outlook.com',
            address: '88 Green Glen Layout, Bellandur, Bangalore',
            registeredPetIds: [],
            joinedDate: DateTime.now().subtract(const Duration(days: 15)),
            notes: 'Regular customer for monthly grooming and herbal bath.',
          ),
        ];
        await _saveToStorage();
      }
    } catch (_) {
      // Graceful fallback
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_customers.map((c) => c.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  Future<void> addCustomer(Customer customer) async {
    _customers.insert(0, customer);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
