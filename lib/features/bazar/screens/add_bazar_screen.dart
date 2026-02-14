import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_housekeeping/core/utils/currency_utils.dart';
import 'package:easy_housekeeping/core/extensions/context_extensions.dart';
import 'package:easy_housekeeping/core/widgets/loading_widget.dart';
import 'package:easy_housekeeping/app_providers.dart';
import 'package:easy_housekeeping/data/database/database.dart';
import 'package:easy_housekeeping/features/bazar/providers/bazar_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_housekeeping/l10n/generated/app_localizations.dart';

class AddBazarScreen extends ConsumerStatefulWidget {
  const AddBazarScreen({super.key});

  @override
  ConsumerState<AddBazarScreen> createState() => _AddBazarScreenState();
}

class _AddBazarScreenState extends ConsumerState<AddBazarScreen> {
  final _marketController = TextEditingController(text: '');
  DateTime _date = DateTime.now();
  int? _purchasedById;
  String? _receiptPath;
  final _lineItems = <_LineItem>[_LineItem()];

  double get _total => _lineItems.fold(0, (sum, item) => sum + item.totalPrice);

  final _suggestedItems = [
    'Miniket Rice',
    'Soybean Oil',
    'Musur Dal',
    'Onion',
    'Potato',
    'Chicken',
    'Eggs',
    'Milk',
    'Sugar',
    'Salt',
    'Holud',
    'Morich',
    'Roshun',
    'Ada',
  ];
  final _marketSuggestions = [
    'Karwan Bazar',
    'Shwapno Dhanmondi',
    'Agora Gulshan',
    'Local Bazar',
    'Meena Bazar',
  ];

  @override
  void dispose() {
    _marketController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final membersAsync = ref.watch(allMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newBazarEntry),
        actions: [TextButton(onPressed: _save, child: Text(l10n.save))],
      ),
      body: membersAsync.when(
        data: (members) => _buildBody(theme, members),
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<HouseholdMember> members) {
    final l10n = AppLocalizations.of(context);
    // Set default purchasedBy to first member if not set
    if (_purchasedById == null && members.isNotEmpty) {
      _purchasedById = members.first.id;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.date,
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_date.day}/${_date.month}/${_date.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _purchasedById,
                      decoration: InputDecoration(
                        labelText: l10n.purchasedBy,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: members
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _purchasedById = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                optionsBuilder: (v) => v.text.isEmpty
                    ? _marketSuggestions
                    : _marketSuggestions.where(
                        (m) => m.toLowerCase().contains(v.text.toLowerCase()),
                      ),
                fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: l10n.marketShop,
                        prefixIcon: const Icon(Icons.store),
                      ),
                      onFieldSubmitted: (_) => onSubmit(),
                    ),
                onSelected: (v) => _marketController.text = v,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.items,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addFromSuggestions,
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(l10n.fromHistory),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _lineItems.length,
                (i) => _buildLineItem(theme, i),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _lineItems.add(_LineItem())),
                icon: const Icon(Icons.add),
                label: Text(l10n.addItem2),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _takeReceiptPhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _receiptPath != null
                      ? l10n.receiptPhotoAdded
                      : l10n.addReceiptPhoto,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Text(l10n.totalColon, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  CurrencyUtils.formatBDT(_total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineItem(ThemeData theme, int index) {
    final l10n = AppLocalizations.of(context);
    final item = _lineItems[index];
    return Dismissible(
      key: ValueKey(item),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => setState(() => _lineItems.removeAt(index)),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (v) => v.text.isEmpty
                    ? _suggestedItems
                    : _suggestedItems.where(
                        (s) => s.toLowerCase().contains(v.text.toLowerCase()),
                      ),
                fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: l10n.itemNumber(index + 1),
                        isDense: true,
                      ),
                      onFieldSubmitted: (_) => onSubmit(),
                    ),
                onSelected: (v) => item.nameController.text = v,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: item.qtyController,
                      decoration: InputDecoration(
                        labelText: l10n.qty,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: DropdownButtonFormField<String>(
                      initialValue: item.unit,
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        isDense: true,
                      ),
                      items: ['kg', 'L', 'pc', 'dozen', 'pack', 'g', 'mL']
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => item.unit = v ?? 'kg'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: item.priceController,
                      decoration: InputDecoration(
                        labelText: l10n.price,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _takeReceiptPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
    );
    if (photo != null) setState(() => _receiptPath = photo.path);
  }

  void _addFromSuggestions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context).frequentlyPurchased,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedItems
                .map(
                  (item) => ActionChip(
                    label: Text(item),
                    onPressed: () {
                      setState(() {
                        final li = _LineItem();
                        li.nameController.text = item;
                        _lineItems.add(li);
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    await db.insertPurchase(
      PurchaseEntriesCompanion(
        date: Value(_date),
        totalAmount: Value(_total),
        marketName: Value(
          _marketController.text.isEmpty ? null : _marketController.text,
        ),
        purchasedById: Value(_purchasedById),
        receiptPhotoPath: Value(_receiptPath),
        createdAt: Value(now),
      ),
    );

    // Insert line items — we don't have real item IDs for these ad-hoc entries
    // so we skip insertLineItem for now (line items need a valid itemId FK)

    ref.invalidate(allPurchasesProvider);

    if (mounted) {
      context.showSnackBar(AppLocalizations.of(context).bazarEntrySaved);
      context.pop();
    }
  }
}

class _LineItem {
  final nameController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  String unit = 'kg';

  double get totalPrice {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    return qty * price;
  }

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }
}
