import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:journal_25_app/services/api_service.dart';
import 'package:journal_25_app/widgets/app_header.dart';
import 'package:journal_25_app/widgets/app_footer.dart';
import 'package:journal_25_app/widgets/article_card.dart';
import 'package:shimmer/shimmer.dart';

class JournalDetailScreen extends StatefulWidget {
  final int journalId;

  const JournalDetailScreen({
    super.key,
    required this.journalId,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _journal;
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('JournalDetailScreen: initState called for journal ID ${widget.journalId}');
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('JournalDetailScreen: Loading data for journal ID ${widget.journalId}');
      final journalResponse = await _apiService.getJournalDetails(widget.journalId);
      print('JournalDetailScreen: Journal data loaded');
      
      final articlesResponse = await _apiService.getArticles(journalId: widget.journalId);
      print('JournalDetailScreen: Articles data loaded');

      if (mounted) {
        setState(() {
          _journal = journalResponse.data;
          _articles = articlesResponse.data['data'];
          _isLoading = false;
          print('JournalDetailScreen: Data loaded successfully');
        });
      }
    } catch (e) {
      print('JournalDetailScreen: Error loading data - $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load journal data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('JournalDetailScreen: Building UI');
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth > 768;
    
    return Scaffold(
      appBar: AppHeader(
        title: _isLoading ? 'Journal Details' : (_journal?['title'] ?? 'Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                      // Journal Header
                      _buildJournalHeader(),
                      
                      // Journal Body
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
                            const SizedBox(height: 32),
                            _buildEditorialBoard(),
                            const SizedBox(height: 32),
                            _buildIssues(),
                            const SizedBox(height: 32),
                            _buildArticles(),
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
  
  Widget _buildJournalHeader() {
    return Stack(
      children: [
        // Cover image or placeholder
        SizedBox(
          height: 240,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: _journal!['cover_image'] ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFF1A3667),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF1A3667),
              child: const Center(
                child: Icon(
                  Icons.science_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
        
        // Gradient overlay
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
        
        // Journal title and info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _journal!['title'] ?? '',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_journal!['publisher'] != null)
                  Text(
                    'Published by ${_journal!['publisher']['name']}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildJournalInfo() {
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
                'ABOUT THE JOURNAL',
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
        
        // Description
        Text(
          _journal!['description'] ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        
        // Journal Metadata
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_journal!['issn'] != null) ...[
                _buildMetadataRow('ISSN', _journal!['issn']),
                const SizedBox(height: 8),
              ],
              if (_journal!['eissn'] != null) ...[
                _buildMetadataRow('E-ISSN', _journal!['eissn']),
                const SizedBox(height: 8),
              ],
              _buildMetadataRow('Publisher', _journal!['publisher']['name'] ?? ''),
              const SizedBox(height: 8),
              _buildMetadataRow('Frequency', 'Quarterly'),
              const SizedBox(height: 8),
              _buildMetadataRow('Language', 'English'),
            ],
          ),
        ),
      ],
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
  
  Widget _buildEditorialBoard() {
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
                'EDITORIAL BOARD',
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
        
        // Board Members
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_journal!['editorial_board'] as List<dynamic>).length,
          itemBuilder: (context, index) {
            final member = _journal!['editorial_board'][index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        member['name'].substring(0, 1),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['name'] ?? '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member['role'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildIssues() {
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
                'RECENT ISSUES',
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
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: (_journal!['recent_issues'] as List<dynamic>).length,
          itemBuilder: (context, index) {
            final issue = _journal!['recent_issues'][index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to issue details
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        issue['issue_number'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        issue['publication_date'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'View Issue',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildArticles() {
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
                'ARTICLES',
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
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _articles.length,
          itemBuilder: (context, index) {
            final article = _articles[index];
            return ArticleCard(
              article: article,
              onTap: () => context.goNamed(
                'article_detail',
                pathParameters: {'articleId': article['article_id'].toString()},
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 200,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 