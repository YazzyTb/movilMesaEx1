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
          // Book cover with price tag and discount indicator
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

              // Discount badge (if on sale)
              if (book.estaEnOferta)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '-${book.porcentajeDescuento.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                    color: book.estaEnOferta
                        ? Colors.orange.shade100
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: book.estaEnOferta
                        ? Border.all(color: Colors.orange.shade300, width: 1)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (book.estaEnOferta) ...[
                        // Precio original tachado
                        Text(
                          '\$${book.precio}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.red,
                            decorationThickness: 2,
                          ),
                        ),
                        // Precio con descuento
                        Text(
                          '\$${book.precioConDescuento}',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ] else
                        Text(
                          '\$${book.precio}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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

                // Mostrar información de la oferta si existe
                if (book.estaEnOferta && book.oferta != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade50],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: Colors.orange.shade300, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.orange.shade700,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.oferta!.nombre,
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mostrar ahorro
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: Colors.green.shade200, width: 0.5),
                    ),
                    child: Text(
                      'Ahorras \${book.ahorroTotal}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                Text(
                  book.descripcion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines:
                      book.estaEnOferta ? 1 : 2, // Menos líneas si hay oferta
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

                    // Mostrar categoría si hay espacio
                    if (book.categoria != null && !book.estaEnOferta) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          book.categoria!.nombre,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // Add to cart button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: book.stock > 0
                            ? () => _showQuantitySelector(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: book.estaEnOferta
                              ? Colors.orange.shade600
                              : colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: book.estaEnOferta ? 4 : 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              book.estaEnOferta
                                  ? Icons.local_fire_department
                                  : Icons.shopping_cart_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              book.estaEnOferta ? 'OFERTA' : 'Agregar',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
                        foregroundColor: book.estaEnOferta
                            ? Colors.orange.shade700
                            : colorScheme.primary,
                        fixedSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: book.estaEnOferta
                                  ? Colors.orange.shade300
                                  : colorScheme.primary,
                              width: 1.5),
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
                  content: Row(
                    children: [
                      Icon(
                        book.estaEnOferta
                            ? Icons.local_fire_department
                            : Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          book.estaEnOferta
                              ? '🔥 ${book.nombre} añadido con oferta!'
                              : '${book.nombre} añadido al carrito',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: book.estaEnOferta
                      ? Colors.orange.shade600
                      : Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 3),
                  action: book.estaEnOferta
                      ? SnackBarAction(
                          label: 'Ver ahorro',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.CART);
                          },
                        )
                      : null,
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
