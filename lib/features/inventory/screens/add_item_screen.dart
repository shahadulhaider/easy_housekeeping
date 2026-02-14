import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_housekeeping/core/extensions/context_extensions.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/inventory/providers/inventory_providers.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _priceController = TextEditingController();
  final _serialController = TextEditingController();
  String _type = 'consumable';
  String _unit = 'kg';
  int? _categoryId;
  int? _locationId;
  String? _condition;

  final _units = [
    'kg',
    'g',
    'L',
    'mL',
    'pc',
    'pack',
    'bottle',
    'cylinder',
    'dozen',
    'bundle',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _priceController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final locationsAsync = ref.watch(allLocationsProvider);

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addItem)),
      body: categoriesAsync.when(
        data: (categories) => locationsAsync.when(
          data: (locations) => _buildForm(context, categories, locations),
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<ItemCategory> categories,
    List<Location> locations,
  ) {
    final filteredCategories = categories
        .where((c) => c.type == _type)
        .toList();

    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'consumable',
                label: Text(l10n.consumable),
                icon: const Icon(Icons.shopping_basket),
              ),
              ButtonSegment(
                value: 'durable',
                label: Text(l10n.durable),
                icon: const Icon(Icons.devices),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() {
              _type = v.first;
              _categoryId = null;
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.itemName,
              prefixIcon: const Icon(Icons.label),
            ),
            validator: (v) => v == null || v.isEmpty ? l10n.required : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _categoryId,
            decoration: InputDecoration(
              labelText: l10n.category,
              prefixIcon: const Icon(Icons.category),
            ),
            items: filteredCategories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _categoryId = v),
            validator: (v) => v == null ? l10n.required : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _locationId,
            decoration: InputDecoration(
              labelText: l10n.location,
              prefixIcon: const Icon(Icons.place),
            ),
            items: locations
                .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
                .toList(),
            onChanged: (v) => setState(() => _locationId = v),
          ),
          const SizedBox(height: 12),
          if (_type == 'consumable') ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: l10n.currentStockLabel,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: InputDecoration(labelText: l10n.unit),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'kg'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minStockController,
              decoration: InputDecoration(
                labelText: l10n.minimumStockAlert,
                prefixIcon: const Icon(Icons.warning_amber),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          if (_type == 'durable') ...[
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: l10n.purchasePrice,
                prefixIcon: const Icon(Icons.payments),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serialController,
              decoration: InputDecoration(
                labelText: l10n.serialNumber,
                prefixIcon: const Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: InputDecoration(
                labelText: l10n.condition,
                prefixIcon: const Icon(Icons.grade),
              ),
              items: [
                DropdownMenuItem(value: 'New', child: Text(l10n.conditionNew)),
                DropdownMenuItem(
                  value: 'Good',
                  child: Text(l10n.conditionGood),
                ),
                DropdownMenuItem(
                  value: 'Fair',
                  child: Text(l10n.conditionFair),
                ),
                DropdownMenuItem(
                  value: 'Needs Repair',
                  child: Text(l10n.conditionNeedsRepair),
                ),
              ],
              onChanged: (v) => setState(() => _condition = v),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt),
            label: Text(l10n.addPhoto),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _saveItem(context),
            child: Text(l10n.saveItem),
          ),
        ],
      ),
    );
  }

  Future<void> _saveItem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;

    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    await db.insertItem(
      ItemsCompanion(
        name: Value(_nameController.text),
        type: Value(_type),
        categoryId: Value(_categoryId!),
        locationId: Value(_locationId),
        currentStock: Value(double.tryParse(_stockController.text) ?? 0),
        unit: Value(_unit),
        minimumStock: Value(double.tryParse(_minStockController.text) ?? 0),
        price: Value(double.tryParse(_priceController.text)),
        serialNumber: Value(
          _serialController.text.isEmpty ? null : _serialController.text,
        ),
        condition: Value(_condition),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    ref.invalidate(allItemsProvider);
    ref.invalidate(consumableItemsProvider);
    ref.invalidate(durableItemsProvider);

    if (context.mounted) {
      context.showSnackBar(AppLocalizations.of(context).itemSaved);
      context.pop();
    }
  }
}
