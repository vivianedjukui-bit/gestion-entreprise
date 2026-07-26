import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/business.dart';
import '../models/stock_item.dart';
import '../theme.dart';
import '../widgets/ledger_row.dart';

class StockScreen extends StatefulWidget {
  final Business business;
  final VoidCallback onChanged;

  const StockScreen({super.key, required this.business, required this.onChanged});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<StockItem> _stock = [];
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.business.id != widget.business.id) _load();
  }

  Future<void> _load() async {
    final stock = await DatabaseHelper.instance.getStock(widget.business.id!);
    setState(() => _stock = stock);
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text.trim());
    final price = int.tryParse(_priceCtrl.text.trim());
    if (name.isEmpty || qty == null || price == null) return;

    await DatabaseHelper.instance.insertStockItem(
      StockItem(businessId: widget.business.id!, name: name, qty: qty, unitPrice: price),
    );
    _nameCtrl.clear();
    _qtyCtrl.clear();
    _priceCtrl.clear();
    await _load();
    widget.onChanged();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Text('Stock — ${widget.business.name}', style: AppText.ledgerTitle()),
        const SizedBox(height: 12),
        ..._stock.map((item) => LedgerRow(
              label: '${item.name} · ${item.qty} unités',
              amount: item.totalValue,
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.paperCard, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajouter un article', style: AppText.body(size: 13).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _field(_nameCtrl, 'Nom de l\'article'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _field(_qtyCtrl, 'Quantité', number: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_priceCtrl, 'Prix unitaire', number: true)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _add,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.white),
                  child: const Text('Ajouter au stock'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

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
