import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/providers/recommendation_provider.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';

class RecommendationCarousel extends StatefulWidget {
  final List<int>? bookIds;

  const RecommendationCarousel({
    Key? key,
    this.bookIds,
  }) : super(key: key);

  @override
  State<RecommendationCarousel> createState() => _RecommendationCarouselState();
}

class _RecommendationCarouselState extends State<RecommendationCarousel> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    final provider =
        Provider.of<RecommendationProvider>(context, listen: false);
    await provider.getRecommendations(bookIds: widget.bookIds);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendationProvider = Provider.of<RecommendationProvider>(context);
    final recommendations = recommendationProvider.recommendations;
    final isLoading = _isLoading || recommendationProvider.isLoading;
    final hasError = recommendationProvider.errorMessage != null;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading state
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        height: 80,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Buscando recomendaciones...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (hasError && recommendations.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        height: 80,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'No se pudieron cargar recomendaciones',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _loadRecommendations,
                child: Text(
                  'Reintentar',
                  style: TextStyle(color: colorScheme.primary, fontSize: 10),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No recommendations
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    // Fixed height for the recommendation section - reduced to avoid overflow
    const double carouselHeight = 120.0;

    return Container(
      height: carouselHeight,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simple header to save space
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: colorScheme.primary,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recomendados para ti',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _loadRecommendations,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 12,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Books list - with fixed height
          SizedBox(
            height: 85, // Fixed height for list (reduced from 95)
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final book = recommendations[index];
                return _RecommendationCard(book: book);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Book book;

  const _RecommendationCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reduced dimensions to avoid overflow
    const double cardWidth = 100.0;
    const double cardHeight = 70.0;
    const double imageWidth = 45.0;
    const double imageHeight = 70.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.BOOK_DETAILS,
          arguments: book,
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book cover
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
              child: SizedBox(
                width: imageWidth,
                height: imageHeight,
                child: Image.network(
                  book.imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.primaryContainer,
                      child: Center(
                        child: Icon(
                          Icons.book,
                          size: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Book info in minimal space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with reduced font
                    Text(
                      book.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    // Price at bottom
                    Row(
                      children: [
                        Text(
                          '\$${book.precio}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.add_circle,
                          color: colorScheme.primary,
                          size: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para añadir al carrito
  Future<void> _addToCart(BuildContext context) async {
    try {
      final cartProvider =
          Provider.of<ShoppingCartProvider>(context, listen: false);
      final success = await cartProvider.addItemToCart(book, 1);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${book.nombre} agregado al carrito',
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, Routes.CART),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo agregar al carrito',
                style: TextStyle(fontSize: 12)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
