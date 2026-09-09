import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  static const String _storageKey = 'pawcare_appointments_data';
  List<ServiceAppointment> _appointments = [];
  bool _isLoading = false;

  List<ServiceAppointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  List<ServiceAppointment> get upcomingAppointments =>
      _appointments.where((a) => a.status == 'Upcoming' || a.status == 'Confirmed').toList();

  List<ServiceAppointment> get completedAppointments =>
      _appointments.where((a) => a.status == 'Completed').toList();

  AppointmentProvider() {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final List decoded = jsonDecode(data);
        _appointments = decoded.map((e) => ServiceAppointment.fromMap(Map<String, dynamic>.from(e), '')).toList();
      } else {
        _appointments = [
          ServiceAppointment(
            id: 'apt_1',
            serviceTitle: 'Full Hydro-Bath & Grooming',
            serviceCategory: 'Grooming',
            petId: 'pet_bruno_1',
            petName: 'Bruno',
            dateTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
            price: 1299.0,
            status: 'Confirmed',
            clinicName: 'PawCare Indiranagar Grooming Salon',
            notes: 'Deshedding treatment + nail clipping included.',
          ),
          ServiceAppointment(
            id: 'apt_2',
            serviceTitle: 'Annual Booster Vaccination (DHPP)',
            serviceCategory: 'Vaccination',
            petId: 'pet_bruno_1',
            petName: 'Bruno',
            dateTime: DateTime.now().add(const Duration(days: 6, hours: 2)),
            price: 850.0,
            status: 'Upcoming',
            clinicName: 'PawCare Veterinary Hospital',
            notes: 'Bring previous vaccination passport.',
          ),
          ServiceAppointment(
            id: 'apt_3',
            serviceTitle: 'General Wellness Consultation',
            serviceCategory: 'Veterinary',
            petId: 'pet_luna_2',
            petName: 'Luna',
            dateTime: DateTime.now().subtract(const Duration(days: 14)),
            price: 600.0,
            status: 'Completed',
            clinicName: 'PawCare Veterinary Hospital',
            notes: 'Ear cleaning and routine health checkup completed.',
          ),
        ];
        await _saveToStorage();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_appointments.map((a) => a.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  Future<void> createAppointment(ServiceAppointment appointment) async {
    _appointments.insert(0, appointment);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateAppointment(ServiceAppointment appointment) async {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> cancelAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: 'Cancelled');
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> rescheduleAppointment(String id, DateTime newDateTime) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(dateTime: newDateTime, status: 'Confirmed');
      notifyListeners();
      await _saveToStorage();
    }
  }
}
