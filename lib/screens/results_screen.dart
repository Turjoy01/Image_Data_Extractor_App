import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/analysis_card.dart';
import '../widgets/comparison_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AnalysisProvider>().reset();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'New Analysis',
          ),
        ],
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          final result = provider.result;
          
          if (result == null) {
            return const Center(
              child: Text('No results available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildResultsHeader(context),
                const SizedBox(height: 20),
                
                // Image Analysis Card
                AnalysisCard(
                  title: 'Comprehensive Image Analysis',
                  icon: Icons.search,
                  children: [
                    _buildAnalysisSection(
                      context,
                      'Full Description & Objects',
                      result.description,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisSection(
                      context,
                      'Extracted Information',
                      result.extractedInfo,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Comparison Section
                _buildComparisonSection(context, result),
                const SizedBox(height: 20),
                
                // Action Buttons
                _buildActionButtons(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.analytics,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete Analysis & Comparison Results',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildComparisonSection(BuildContext context, result) {
    return Column(
      children: [
        Text(
          result.comparisonTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Comparison Cards Grid
        Row(
          children: [
            Expanded(
              child: ComparisonCard(
                label: result.imageLabel,
                value: result.imageValue,
                source: 'Extracted from image',
                isImageData: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ComparisonCard(
                label: result.referenceLabel,
                value: result.referenceValueDisplay,
                source: result.referenceSource,
                isImageData: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // AI Analysis Result
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.smart_toy,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI-Powered Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.comparison,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AnalysisProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              provider.reset();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Analyze Another Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Results'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
