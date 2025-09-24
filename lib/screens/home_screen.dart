import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/comparison_type_selector.dart';
import '../widgets/reference_value_input.dart';
import '../widgets/additional_context_input.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_card.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turjoy\'s Image Analysis & Universal Comparison App'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<AnalysisProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                _buildMainContent(context, provider),
                if (provider.isLoading) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AnalysisProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Image Upload Section
            ImageUploadWidget(
              selectedImage: provider.selectedImage,
              onImageSelected: provider.setSelectedImage,
              isLoading: provider.isLoading,
            ),
            const SizedBox(height: 16),
            
            // Comparison Type Selector
            ComparisonTypeSelector(
              selectedType: provider.selectedComparisonType,
              onTypeChanged: provider.setComparisonType,
            ),
            const SizedBox(height: 16),
            
            // Reference Value Input
            ReferenceValueInput(
              value: provider.referenceValue,
              comparisonType: provider.selectedComparisonType,
              onChanged: provider.setReferenceValue,
            ),
            const SizedBox(height: 16),
            
            // Additional Context Input
            AdditionalContextInput(
              value: provider.additionalContext,
              onChanged: provider.setAdditionalContext,
            ),
            const SizedBox(height: 24),
            
            // Analyze Button
            _buildAnalyzeButton(context, provider),
            const SizedBox(height: 16),
            
            // Error Display
            if (provider.error != null)
              ErrorCard(
                error: provider.error!,
                onDismiss: provider.clearError,
              ),
            
            // Results Navigation
            if (provider.result != null)
              _buildResultsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Turjoy\'s Image Analysis & Universal Comparison App',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload any image format - extract and compare prices, temperatures, dates, locations, products and more!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, AnalysisProvider provider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.shade400,
            Colors.cyan.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.canAnalyze && !provider.isLoading
            ? () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await provider.analyzeImage();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: provider.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Analyzing Everything...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Analyze & Compare Everything',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildResultsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.lightBlue.shade50,
            Colors.lightBlue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.shade200,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: Colors.cyan.shade700,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete Analysis & Comparison Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan.shade800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your image has been analyzed successfully!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.cyan.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResultsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text(
                  'View Complete Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
