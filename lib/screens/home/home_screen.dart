import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journal_25_app/services/api_service.dart';
import 'package:journal_25_app/widgets/journal_card.dart';
import 'package:journal_25_app/widgets/article_card.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  List<dynamic> _journals = [];
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('HomeScreen: initState called');
    _loadData();
  }

  Future<void> _loadData() async {
    print('HomeScreen: _loadData called');
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('HomeScreen: Fetching journals and articles...');
      
      // Load journals
      final journalsResponse = await _apiService.getJournals();
      print('HomeScreen: Journals response - ${journalsResponse.statusCode}');
      if (journalsResponse.statusCode != 200) {
        throw Exception('Failed to load journals: ${journalsResponse.statusCode}');
      }
      
      // Load articles
      final articlesResponse = await _apiService.getArticles();
      print('HomeScreen: Articles response - ${articlesResponse.statusCode}');
      if (articlesResponse.statusCode != 200) {
        throw Exception('Failed to load articles: ${articlesResponse.statusCode}');
      }

      if (mounted) {
        setState(() {
          _journals = journalsResponse.data['data'] ?? [];
          _articles = articlesResponse.data['data'] ?? [];
          _isLoading = false;
          print('HomeScreen: Data loaded - ${_journals.length} journals, ${_articles.length} articles');
        });
      }
    } catch (e) {
      print('HomeScreen: Error loading data - $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.goNamed('profile'),
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
              : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    print('HomeScreen: Building content with ${_journals.length} journals and ${_articles.length} articles');
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Journals section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Featured Journals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          _journals.isEmpty
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text('No journals available')),
                  ),
                )
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _journals.length,
                      itemBuilder: (context, index) {
                        final journal = _journals[index];
                        return JournalCard(
                          journal: journal,
                          onTap: () {
                            if (journal['journal_id'] != null) {
                              print('HomeScreen: Navigating to journal ${journal['journal_id']}');
                              context.goNamed(
                                'journal_detail',
                                pathParameters: {'journalId': journal['journal_id'].toString()},
                              );
                            } else {
                              print('HomeScreen: Cannot navigate - journal_id is null');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Journal ID not available')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
          
          // Articles section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Latest Articles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          _articles.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(child: Text('No articles available')),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = _articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () {
                          if (article['article_id'] != null) {
                            print('HomeScreen: Navigating to article ${article['article_id']}');
                            context.goNamed(
                              'article_detail',
                              pathParameters: {'articleId': article['article_id'].toString()},
                            );
                          } else {
                            print('HomeScreen: Cannot navigate - article_id is null');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Article ID not available')),
                            );
                          }
                        },
                      );
                    },
                    childCount: _articles.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 24,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 24,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            },
            childCount: 5,
          ),
        ),
      ],
    );
  }
} 