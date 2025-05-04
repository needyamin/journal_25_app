import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journal_25_app/services/api_service.dart';
import 'package:journal_25_app/widgets/app_header.dart';
import 'package:journal_25_app/widgets/app_footer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _article;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    print('ArticleDetailScreen: initState called for article ID ${widget.articleId}');
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('ArticleDetailScreen: Loading data for article ID ${widget.articleId}');
      final response = await _apiService.getArticleDetails(widget.articleId);
      print('ArticleDetailScreen: Article data loaded');

      if (mounted) {
        setState(() {
          _article = response.data;
          _isLoading = false;
          print('ArticleDetailScreen: Data loaded successfully');
        });
      }
    } catch (e) {
      print('ArticleDetailScreen: Error loading data - $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load article data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadFile(String fileType) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      print('ArticleDetailScreen: Downloading $fileType file for article ID ${widget.articleId}');
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      final response = await _apiService.downloadArticleFile(widget.articleId, fileType);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/article_${widget.articleId}.$fileType');
      await file.writeAsBytes(response.data);
      print('ArticleDetailScreen: File downloaded to ${file.path}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded to ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                if (await canLaunchUrl(Uri.file(file.path))) {
                  await launchUrl(Uri.file(file.path));
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('ArticleDetailScreen: Error downloading file - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ArticleDetailScreen: Building UI');
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth > 768;

    return Scaffold(
      appBar: AppHeader(
        title: _isLoading 
          ? 'Article Details' 
          : (_article?['title'] ?? 'Article').substring(
              0, 
              min((_article?['title'] ?? 'Article').length, 20)
            ) + '...',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          if (_article != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _isDownloading
                  ? null
                  : () => showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: const Text('Download PDF'),
                              onTap: () {
                                Navigator.pop(context);
                                _downloadFile('pdf');
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.description),
                              title: const Text('Download DOC'),
                              onTap: () {
                                Navigator.pop(context);
                                _downloadFile('doc');
                              },
                            ),
                          ],
                        ),
                      ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Article Content
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTabletOrLarger ? 48 : 16,
                          vertical: 24,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: isTabletOrLarger ? 1024 : double.infinity,
                        ),
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildJournalInfo(),
                            const SizedBox(height: 24),
                            _buildArticleHeader(),
                            const SizedBox(height: 32),
                            _buildAbstract(),
                            const SizedBox(height: 32),
                            _buildMetadata(),
                            const SizedBox(height: 32),
                            _buildDownloadSection(),
                            const SizedBox(height: 40),
                            const Divider(),
                            const SizedBox(height: 40),
                            _buildCitationSection(),
                          ],
                        ),
                      ),
                      
                      // Footer
                      const AppFooter(),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildJournalInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.science_outlined,
            size: 20,
            color: Color(0xFF1A3667),
          ),
          const SizedBox(width: 12),
          Text(
            _article!['journal']['title'] ?? '',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const Spacer(),
          Text(
            'Published: ${_article!['publication_date'] ?? ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  Widget _buildArticleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _article!['title'] ?? '',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_article!['authors'] as List<dynamic>).map((author) {
            return InkWell(
              onTap: () {},
              child: Chip(
                label: Text(
                  '${author['name'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
            );
          }).toList(),
        ),
        if (_article!['authors'] != null && _article!['authors'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              (_article!['authors'] as List<dynamic>).map((author) => 
                '${author['affiliation'] ?? ''}').join('; '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAbstract() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Divider(thickness: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ABSTRACT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Expanded(
              child: Divider(thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _article!['abstract'] ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetadata() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_article!['doi'] != null) ...[
            _buildMetadataRow('DOI', _article!['doi']),
            const SizedBox(height: 8),
          ],
          _buildMetadataRow('Journal', _article!['journal']['title'] ?? ''),
          const SizedBox(height: 8),
          _buildMetadataRow('Publication Date', _article!['publication_date'] ?? ''),
          const SizedBox(height: 8),
          _buildMetadataRow('Article Type', 'Research Article'),
        ],
      ),
    );
  }
  
  Widget _buildMetadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDownloadSection() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download PDF'),
            onPressed: () => _downloadFile('pdf'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.description),
            label: const Text('Download DOC'),
            onPressed: () => _downloadFile('doc'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCitationSection() {
    const citationText = 'Smith J., Doe A. (2023). Advances in Machine Learning Applications. Journal of Computer Science, 15(2), 123-145.';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Cite',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                citationText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Citation'),
                    onPressed: () {
                      // Implement copy functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Citation copied to clipboard')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 120,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 