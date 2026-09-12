import 'package:flutter/material.dart';
import '../services/loan_service.dart';
import '../models/loan.dart';

class LoanProvider extends ChangeNotifier {
  final LoanService _loanService = LoanService();
  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _error;

  List<Loan> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLoans() async {
    _isLoading = true;
    notifyListeners();

    try {
      _loans = await _loanService.getLoans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar préstamos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}