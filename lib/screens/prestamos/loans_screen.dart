import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/loan_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoanProvider>().loadLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Préstamos'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.loans.isEmpty
          ? const Center(child: Text('No tienes préstamos activos'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.loans.length,
        itemBuilder: (context, index) {
          final loan = provider.loans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(loan.tipoLabel),
              subtitle: Text('Cuota: ${Formatters.formatCurrency(loan.cuotaMensual)}'),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.formatCurrency(loan.saldoPendiente),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(loan.estadoLabel,
                      style: TextStyle(color: loan.estadoColor, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}