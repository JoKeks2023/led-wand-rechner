import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/led_models.dart';
import '../../providers/app_providers.dart';
import '../../services/led_calculation_service.dart';
import '../../services/localization_service.dart';

class LEDInputForm extends StatefulWidget {
  final Project project;
  final List<LEDBrand> brands;
  final Function(Project) onProjectUpdated;

  const LEDInputForm({
    Key? key,
    required this.project,
    required this.brands,
    required this.onProjectUpdated,
  }) : super(key: key);

  @override
  State<LEDInputForm> createState() => _LEDInputFormState();
}

class _LEDInputFormState extends State<LEDInputForm> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _modulePriceController;
  late TextEditingController _installationCostController;
  late TextEditingController _serviceWarrantyCostController;
  late TextEditingController _shippingCostController;

  String? _selectedBrandId;
  String? _selectedModelId;
  String? _selectedVariantId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProjectData();
  }

  void _initializeControllers() {
    _widthController = TextEditingController(text: '1000');
    _heightController = TextEditingController(text: '600');
    _modulePriceController = TextEditingController(text: '400');
    _installationCostController = TextEditingController(text: '0');
    _serviceWarrantyCostController = TextEditingController(text: '0');
    _shippingCostController = TextEditingController(text: '0');
  }

  void _loadProjectData() {
    if (widget.project.parametersJson.isNotEmpty) {
      final params = widget.project.parametersJson;
      _widthController.text = (params['width_mm'] ?? 1000).toString();
      _heightController.text = (params['height_mm'] ?? 600).toString();
      _modulePriceController.text = (params['module_price'] ?? 400).toString();
      _installationCostController.text = (params['installation_cost'] ?? 0).toString();
      _serviceWarrantyCostController.text = (params['service_warranty_cost'] ?? 0).toString();
      _shippingCostController.text = (params['shipping_cost'] ?? 0).toString();
      _selectedBrandId = params['selected_brand_id'];
      _selectedModelId = params['selected_model_id'];
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _modulePriceController.dispose();
    _installationCostController.dispose();
    _serviceWarrantyCostController.dispose();
    _shippingCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LEDDataProvider, CalculationProvider>(
      builder: (context, ledDataProvider, calcProvider, _) {
        final filteredModels = _selectedBrandId == null
            ? []
            : ledDataProvider.models
                .where((m) => m.brandId == _selectedBrandId)
                .toList();

        final selectedModel = _selectedModelId == null
            ? null
            : ledDataProvider.getModel(_selectedModelId!);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  localization.ledParamsBrand,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedBrandId,
                  hint: Text(localization.ledParamsSelectBrand),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(localization.ledParamsSelectBrand),
                    ),
                    ...ledDataProvider.brands.map((brand) {
                      return DropdownMenuItem<String>(
                        value: brand.id,
                        child: Text(brand.name),
                      );
                    }),
                  ],
                  onChanged: (brandId) {
                    setState(() {
                      _selectedBrandId = brandId;
                      _selectedModelId = null;
                      _selectedVariantId = null;
                    });
                    ledDataProvider.selectBrand(brandId);
                  },
                ),
                const SizedBox(height: 8),

                // Model Dropdown
                if (_selectedBrandId != null) ...[
                  Text(
                    localization.ledParamsModel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedModelId,
                    hint: Text(localization.ledParamsSelectModel),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(localization.ledParamsSelectModel),
                      ),
                      ...filteredModels.map((model) {
                        return DropdownMenuItem<String>(
                          value: model.id,
                          child: Text(model.modelName),
                        );
                      }),
                    ],
                    onChanged: (modelId) {
                      setState(() {
                        _selectedModelId = modelId;
                        _selectedVariantId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                // Variant Dropdown
                if (_selectedModelId != null &&
                    ledDataProvider.getVariantsForModel(_selectedModelId!).isNotEmpty) ...[
                  Text(
                    localization.ledParamsVariant,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedVariantId,
                    items: ledDataProvider
                        .getVariantsForModel(_selectedModelId!)
                        .map((variant) {
                      return DropdownMenuItem<String>(
                        value: variant.id,
                        child: Text(variant.variantName),
                      );
                    }).toList(),
                    onChanged: (variantId) {
                      setState(() => _selectedVariantId = variantId);
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                // Dimensions
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localization.ledParamsWidthMm,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _calculate(ledDataProvider),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localization.ledParamsHeightMm,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _calculate(ledDataProvider),
                      ),
                    ),
                  ],
                ),

                // Costs
                Text(
                  localization.costTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _modulePriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localization.costModulePrice,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _calculate(ledDataProvider),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _installationCostController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localization.costInstallation,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _calculate(ledDataProvider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _serviceWarrantyCostController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localization.costServiceWarranty,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _calculate(ledDataProvider),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _shippingCostController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localization.costShipping,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _calculate(ledDataProvider),
                      ),
                    ),
                  ],
                ),

                // Save Button
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _saveProject(),
                  icon: const Icon(Icons.save),
                  label: Text(localization.commonSave),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _calculate(LEDDataProvider ledDataProvider) {
    if (_selectedModelId == null) return;

    final model = ledDataProvider.getModel(_selectedModelId!);
    if (model == null) return;

    final width = double.tryParse(_widthController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final modulePrice = double.tryParse(_modulePriceController.text);
    final installationCost = double.tryParse(_installationCostController.text);
    final serviceWarrantyCost = double.tryParse(_serviceWarrantyCostController.text);
    final shippingCost = double.tryParse(_shippingCostController.text);

    final numberOfModules = ledCalculationService.calculateNumberOfModules(
      wallWidthMm: width,
      wallHeightMm: height,
      moduleSize: model.specsJson?['module_size_mm'] ?? '320x160',
    );

    context.read<CalculationProvider>().calculate(
          widthMm: width,
          heightMm: height,
          pixelPitchMm: model.pixelPitchMm,
          wattagePerLedMa: model.wattagePerLedMa,
          modulePriceEur: modulePrice,
          installationCostEur: installationCost,
          serviceWarrantyCostEur: serviceWarrantyCost,
          shippingCostEur: shippingCost,
          numberOfModules: numberOfModules > 0 ? numberOfModules : null,
        );
  }

  void _saveProject() {
    final updatedProject = widget.project.copyWith(
      selectedBrandId: _selectedBrandId,
      selectedModelId: _selectedModelId,
      selectedVariantId: _selectedVariantId,
      parametersJson: {
        'width_mm': double.tryParse(_widthController.text) ?? 0,
        'height_mm': double.tryParse(_heightController.text) ?? 0,
        'module_price': double.tryParse(_modulePriceController.text) ?? 0,
        'installation_cost': double.tryParse(_installationCostController.text) ?? 0,
        'service_warranty_cost': double.tryParse(_serviceWarrantyCostController.text) ?? 0,
        'shipping_cost': double.tryParse(_shippingCostController.text) ?? 0,
        'selected_brand_id': _selectedBrandId,
        'selected_model_id': _selectedModelId,
      },
      resultsJson: context.read<CalculationProvider>().currentResults?.toJson(),
    );

    widget.onProjectUpdated(updatedProject);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.commonSuccess)),
    );
  }
}
