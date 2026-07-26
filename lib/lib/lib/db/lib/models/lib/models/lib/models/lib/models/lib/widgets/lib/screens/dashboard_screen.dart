import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/business.dart';
import '../models/stock_item.dart';
import '../models/transaction_entry.dart';
import '../theme.dart';
import '../widgets/ledger_row.dart';

class DashboardScreen extends StatefulWidget {
  final Business business;
  final int refreshTick;

  const DashboardScreen({super.key, required this.business, required this.refreshTick});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionEntry> _all = [];
  List<StockItem> _stock = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.business.id != widget.business.id || oldWidget.refreshTick != widget.refreshTick) {
      _load();
    }
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final all = await db.getTransactions(widget.business.id!);
    final stock = await db.getStock(widget.business.id!);
    setState(() {
      _all = all;
      _stock = stock;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sales = _all.where((t) => t.type == EntryType.sale);
    final expenses = _all.where((t) => t.type == EntryType.expense);
    final totalSales = sales.fold<int>(0, (s, t) => s + t.amount);
    final totalExpenses = expenses.fold<int>(0, (s, t) => s + t.amount);
    final net = totalSales - totalExpenses;
    final stockValue = _stock.fold<int>(0, (s, i) => s + i.totalValue);

    final recent = [..._all]..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Text('Bilan — ${widget.business.name}', style: AppText.ledgerTitle()),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            _StatCard(label: 'Recettes', value: totalSales, color: AppColors.green),
            _StatCard(label: 'Dépenses', value: totalExpenses, color: AppColors.red),
            _StatCard(label: 'Valeur du stock', value: stockValue, color: AppColors.ink),
            _StatCard(
              label: 'Bénéfice net',
              value: net,
              color: net >= 0 ? AppColors.green : AppColors.red,
              background: net >= 0 ? const Color(0xFFE1EEE3) : const Color(0xFFF3E0DD),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('DERNIÈRES ÉCRITURES', style: AppText.label()),
        const SizedBox(height: 4),
        ...recent.take(8).map(
              (t) => LedgerRow(
                label: t.label,
                amount: t.amount,
                positive: t.type == EntryType.sale,
              ),
            ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color? background;

  const _StatCard({required this.label, required this.value, required this.color, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background ?? AppColors.paperCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppText.label()),
          const SizedBox(height: 2),
          Text(formatFcfa(value), style: AppText.amount(size: 14, color: color, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
