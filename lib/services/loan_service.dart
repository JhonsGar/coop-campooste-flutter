import '../models/loan.dart';
import 'mock_data.dart';

class LoanService {
  Future<List<Loan>> getLoans() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.mockLoans;
  }
}