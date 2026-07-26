import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/business.dart';
import '../models/transaction_entry.dart';
import '../theme.dart';
import '../widgets/ledger_row.dart';

class ExpensesScreen extends StatefulWidget {
  final Business business;
  final VoidCallback onChanged;

  const ExpensesScreen({super.key, required this.business, required this.onChanged});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<TransactionEntry> _expenses = [];
  final _labelCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.business.id != widget.business.id) _load();
  }

  Future<void> _load() async {
    final expenses = await DatabaseHelper.instance.getTransactions(widget.business.id!, type: EntryType.expense);
    setState(() => _expenses = expenses);
  }

  Future<void> _add() async {
    final label = _labelCtrl.text.trim();
    final amount = int.tryParse(_amountCtrl.text.trim());
    if (label.isEmpty || amount == null) return;

    await DatabaseHelper.instance.insertTransaction(
      TransactionEntry(
        businessId: widget.business.id!,
        type: EntryType.expense,
        label: label,
        amount: amount,
        date: DateTime.now(),
      ),
    );
    _labelCtrl.clear();
    _amountCtrl.clear();
    await _load();
    widget.onChanged();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Text('Dépenses — ${widget.business.name}', style: AppText.ledgerTitle()),
        const SizedBox(height: 12),
        ..._expenses.map((e) => LedgerRow(
              date: _fmtDate(e.date),
              label: e.label,
              amount: e.amount,
              positive: false,
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.paperCard, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enregistrer une dépense', style: AppText.body(size: 13).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _field(_labelCtrl, 'Description'),
              const SizedBox(height: 8),
              _field(_amountCtrl, 'Montant (FCFA)', number: true),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _add,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
                  child: const Text('Enregistrer la dépense'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}';

  Widget _field(TextEditingController ctrl, String hint, {bool number = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
