import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/widgets/quantity_selector_dialog.dart';
import 'package:provider/provider.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Book cover with price tag and stock indicator
          Stack(
            children: [
              // Cover image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Hero(
                    tag: 'book-image-${book.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: _BookCoverImage(imageUrl: book.imagen),
                    ),
                  ),
                ),
              ),

              // Price tag
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '\$${book.precio}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Stock indicator
              if (book.stock <= 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'AGOTADO',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Book info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.nombre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  book.descripcion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: book.stock > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Stock: ${book.stock}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: book.stock > 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Add to cart button - Now just an icon button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: book.stock > 0
                            ? () => _showQuantitySelector(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details button
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.BOOK_DETAILS,
                          arguments: book,
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.primary,
                        fixedSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: colorScheme.primary, width: 1.5),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantitySelector(BuildContext context) {
    final cartProvider =
        Provider.of<ShoppingCartProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => QuantitySelectorDialog(
        book: book,
        onAddToCart: (quantity) async {
          // Cerrar el diálogo
          Navigator.of(dialogContext).pop();

          // Mostrar diálogo de carga
          BuildContext? loadingDialogContext =
              await _showLoadingDialog(context, 'Añadiendo al carrito...');

          try {
            // Realizar la operación
            final success = await cartProvider.addItemToCart(book, quantity);

            // Cerrar diálogo de carga si sigue visible
            if (loadingDialogContext != null &&
                Navigator.canPop(loadingDialogContext)) {
              Navigator.of(loadingDialogContext).pop();
            }

            // Verificar si el widget aún está montado
            if (!context.mounted) return;

            // Mostrar el resultado
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${book.nombre} añadido al carrito'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(cartProvider.errorMessage ??
                      'Error al añadir al carrito'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // Cerrar diálogo de carga si sigue visible
            if (loadingDialogContext != null &&
                Navigator.canPop(loadingDialogContext)) {
              Navigator.of(loadingDialogContext).pop();
            }

            // Verificar si el widget aún está montado
            if (!context.mounted) return;

            // Mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  Future<BuildContext?> _showLoadingDialog(
      BuildContext context, String message) async {
    BuildContext? dialogContext;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return dialogContext;
  }
}

class _BookCoverImage extends StatelessWidget {
  final String imageUrl;

  const _BookCoverImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Image.asset(
              'assets/placeholder_book.jpg',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
