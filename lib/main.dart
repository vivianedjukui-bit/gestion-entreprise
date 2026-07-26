import 'package:flutter/material.dart';

import 'db/database_helper.dart';
import 'models/business.dart';
import 'screens/dashboard_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/expenses_screen.dart';
import 'theme.dart';

void main() {
  runApp(const GestionEntrepriseApp());
}

class GestionEntrepriseApp extends StatelessWidget {
  const GestionEntrepriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Entreprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cover,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Business> _businesses = [];
  Business? _active;
  int _navIndex = 0;
  int _refreshTick = 0;

  static const _labels = ['Bilan', 'Stock', 'Caisse', 'Dépenses'];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    final list = await DatabaseHelper.instance.getBusinesses();
    setState(() {
      _businesses = list;
      _active = list.isNotEmpty ? list.first : null;
    });
  }

  void _bump() => setState(() => _refreshTick++);

  Color _hexToColor(String hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    if (_active == null) {
      return const Scaffold(
        backgroundColor: AppColors.cover,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cover,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: _buildBody()),
                        _buildBottomNav(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes Carnets', style: AppText.ledgerTitle(size: 20, color: AppColors.paper)),
              Text('${_businesses.length} entreprises',
                  style: AppText.amount(size: 11, color: const Color(0xFF8FA097), weight: FontWeight.w400)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _businesses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final b = _businesses[i];
                final isActive = b.id == _active!.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _active = b;
                    _navIndex = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    transform: Matrix4.translationValues(0, isActive ? 0 : 4, 0),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.paper : _hexToColor(b.colorHex).withOpacity(0.9),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Text(
                      b.name,
                      style: AppText.body(size: 12, color: isActive ? AppColors.ink : Colors.white)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1:
        return StockScreen(business: _active!, onChanged: _bump);
      case 2:
        return SalesScreen(business: _active!, onChanged: _bump);
      case 3:
        return ExpensesScreen(business: _active!, onChanged: _bump);
      default:
        return DashboardScreen(business: _active!, refreshTick: _refreshTick);
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE4DCC0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_labels.length, (i) {
          final selected = _navIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _navIndex = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.paperCard : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _labels[i],
                style: AppText.body(size: 12, color: selected ? AppColors.ink : AppColors.muted)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }),
      ),
    );
  }
}
