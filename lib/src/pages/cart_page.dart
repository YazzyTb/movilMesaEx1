import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/widgets/custom_gradient_background.dart';
import 'package:exam1_software_movil/src/widgets/nova_logo.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/widgets/recommendation_carousel.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _mounted = true;
  late AnimationController _animationController;
  late Animation<double> _cartAnimation;

  @override
  void initState() {
    super.initState();
    print('CartPage: initState called');

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // Use addPostFrameCallback to safely load data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('CartPage: Running post-frame callback');
      _loadCart();
    });
  }

  @override
  void dispose() {
    print('CartPage: dispose called');
    _animationController.dispose();
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadCart() async {
    print('CartPage: _loadCart called, mounted: $_mounted');
    if (!_mounted) {
      print('CartPage: Not mounted, skipping cart load');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cartProvider =
        Provider.of<ShoppingCartProvider>(context, listen: false);
    print('CartPage: Calling loadCart() on provider');
    await cartProvider.loadCart();

    if (!_mounted) {
      print('CartPage: Not mounted after loadCart, skipping state update');
      return;
    }

    print(
        'CartPage: Cart loaded, items: ${cartProvider.items.length}, error: ${cartProvider.errorMessage}');
    setState(() {
      _isLoading = false;
    });

    // Start animation when cart is loaded
    _animationController.forward();
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    print(
        'CartPage: _updateQuantity called for item ${item.id}, new quantity: $newQuantity');
    if (!_mounted) {
      print('CartPage: Not mounted, skipping quantity update');
      return;
    }

    final cartProvider =
        Provider.of<ShoppingCartProvider>(context, listen: false);
    if (newQuantity <= 0) {
      print('CartPage: Removing item ${item.id} (quantity <= 0)');
      await cartProvider.removeCartItem(item.id!);
    } else {
      print('CartPage: Updating quantity for item ${item.id} to $newQuantity');
      await cartProvider.updateCartItemQuantity(item.id!, newQuantity);
    }
  }

  Future<void> _removeItem(int itemId) async {
    print('CartPage: _removeItem called for item $itemId');
    if (!_mounted) {
      print('CartPage: Not mounted, skipping item removal');
      return;
    }

    final cartProvider =
        Provider.of<ShoppingCartProvider>(context, listen: false);
    await cartProvider.removeCartItem(itemId);
  }

  Future<void> _showClearCartDialog() async {
    final cartProvider =
        Provider.of<ShoppingCartProvider>(context, listen: false);
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Vaciar carrito?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Esta acción eliminará todos los productos de tu carrito.'),
                Text('¿Estás seguro que deseas continuar?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: theme.colorScheme.secondary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Vaciar',
                  style: TextStyle(color: theme.colorScheme.error)),
              onPressed: () {
                Navigator.of(context).pop();
                cartProvider.clearCart();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('CartPage: build called, isLoading: $_isLoading');
    final cartProvider = Provider.of<ShoppingCartProvider>(context);
    final cartItems = cartProvider.items;
    print(
        'CartPage: Current items count: ${cartItems.length}, provider isLoading: ${cartProvider.isLoading}');

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Show loading view if we're still loading or if provider is loading and we have no items
    if (_isLoading || (cartProvider.isLoading && cartItems.isEmpty)) {
      print('CartPage: Showing loading view');
      return _LoadingView();
    }

    // Show empty view only if we're not loading and there are no items
    if (cartItems.isEmpty) {
      print('CartPage: Showing empty cart view');
      return _EmptyCartView(onRefresh: _loadCart);
    }

    print('CartPage: Showing cart with ${cartItems.length} items');
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de compras'),
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined),
              onPressed: _showClearCartDialog,
              tooltip: 'Vaciar carrito',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCart,
        child: CustomScrollView(
          slivers: [
            // Lista de elementos del carrito
            SliverToBoxAdapter(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: size.height * 0.3,
                  maxHeight: size.height * 0.65, // Limitar altura máxima
                ),
                child: _buildCartContent(),
              ),
            ),

            // Recomendaciones (si hay elementos en el carrito)
            if (cartItems.isNotEmpty)
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200, // Altura máxima para recomendaciones
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RecommendationCarousel(
                      bookIds: cartItems.map((item) => item.book.id).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: cartItems.isNotEmpty ? _buildTotalBar() : null,
    );
  }

  double _calculateTotal(List<CartItem> items) {
    print('CartPage: Calculating total for ${items.length} items');
    return items.fold(
        0,
        (sum, item) =>
            sum + (item.quantity! * (double.tryParse(item.book.precio) ?? 0)));
  }

  Widget _buildCartContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cartProvider = Provider.of<ShoppingCartProvider>(context);
    final cartItems = cartProvider.items;
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NovaLogo(
                size: 32,
                isDark: isDark,
              ),
              const Spacer(),
              Text(
                "Mi Carrito",
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              const SizedBox(width: 32), // Balance the logo
            ],
          ),
        ),

        // Loading indicator at the top when refreshing but we already have items
        if (cartProvider.isLoading && cartItems.isNotEmpty)
          LinearProgressIndicator(
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            color: colorScheme.primary,
          ),

        // Error message if any
        if (cartProvider.errorMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cartProvider.errorMessage!,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: colorScheme.error),
                  onPressed: _loadCart,
                ),
              ],
            ),
          ),

        // Cart items with animation
        Expanded(
          child: FadeTransition(
            opacity: _cartAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_cartAnimation),
              child: RefreshIndicator(
                onRefresh: _loadCart,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Cart items
                    if (cartItems.isNotEmpty)
                      ...List.generate(cartItems.length, (index) {
                        final cartItem = cartItems[index];
                        print(
                            'CartPage: Building item at index $index, id: ${cartItem.id}');
                        return _CartItemCard(
                          cartItem: cartItem,
                          onUpdateQuantity: (newQuantity) =>
                              _updateQuantity(cartItem, newQuantity),
                          onRemove: () => _removeItem(cartItem.id!),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBar() {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<ShoppingCartProvider>(context);
    final cartItems = cartProvider.items;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen del total y checkout
            Row(
              children: [
                // Información del total
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${_calculateTotal(cartItems).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón de checkout
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: cartProvider.isLoading
                        ? null
                        : () {
                            print('CartPage: Checkout button pressed');
                            Navigator.of(context).pushNamed(Routes.PAYMENT);
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: cartProvider.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Comprar ahora'),
                              SizedBox(width: 8),
                              Icon(Icons.shopping_cart_checkout, size: 18),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('LoadingView: Building loading view');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return CustomGradientBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NovaLogo(
                      size: 32,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    Text(
                      "Mi Carrito",
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    const SizedBox(width: 32), // Balance the logo
                  ],
                ),
              ),

              // Loading animation
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cargando tu carrito...',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Estamos preparando tus productos y recomendaciones',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyCartView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return CustomGradientBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: CustomScrollView(
              slivers: [
                // Logo and Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NovaLogo(
                          size: 32,
                          isDark: isDark,
                        ),
                        const Spacer(),
                        Text(
                          "Mi Carrito",
                          style: theme.textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        const SizedBox(width: 32), // Balance the logo
                      ],
                    ),
                  ),
                ),

                // Empty state
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tu carrito está vacío',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Encuentra libros increíbles para agregar a tu carrito',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            print('EmptyCartView: Browse books button pressed');
                            Navigator.pushReplacementNamed(
                                context, Routes.BOOKS);
                          },
                          icon: const Icon(Icons.book_outlined),
                          label: const Text('Explorar Librería'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recommendations title
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Libros que podrían interesarte',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recommendations for empty cart
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Valor más pequeño pero suficiente
                        maxHeight: 250,
                      ),
                      child: const RecommendationCarousel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.cartItem,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    print('CartItemCard: Building card for item ${cartItem.id}');
    final book = cartItem.book;
    if (book == null) {
      print('CartItemCard: Warning - book is null for item ${cartItem.id}');
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover with tap capability to navigate to details
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.BOOK_DETAILS,
                      arguments: book,
                    );
                  },
                  child: Hero(
                    tag: 'book_image_${book.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 80,
                        height: 120,
                        child: Image.network(
                          book.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.book,
                                  size: 36,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Book details with flexible layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book title with tap capability to navigate to details
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.BOOK_DETAILS,
                            arguments: book,
                          );
                        },
                        child: Text(
                          book.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Price with quantity
                      Row(
                        children: [
                          Text(
                            '\$${book.precio}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' × ${cartItem.quantity}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Stock info if low
                      if (book.stock < 5)
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: book.stock > 0
                                ? Colors.orange.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book.stock > 0
                                ? 'Quedan ${book.stock} unidades'
                                : 'Sin existencias',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: book.stock > 0
                                  ? Colors.orange.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Action buttons in a row
                      Row(
                        children: [
                          // Quantity controls
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Decrease button
                                InkWell(
                                  onTap: cartItem.quantity! > 1
                                      ? () => onUpdateQuantity(
                                          cartItem.quantity! - 1)
                                      : null,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: cartItem.quantity! > 1
                                          ? colorScheme.primaryContainer
                                              .withOpacity(0.7)
                                          : colorScheme.surfaceVariant
                                              .withOpacity(0.5),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        left: Radius.circular(7),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: cartItem.quantity! > 1
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                ),

                                // Quantity display
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${cartItem.quantity}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Increase button
                                InkWell(
                                  onTap: cartItem.quantity! < book.stock
                                      ? () => onUpdateQuantity(
                                          cartItem.quantity! + 1)
                                      : null,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: cartItem.quantity! < book.stock
                                          ? colorScheme.primaryContainer
                                              .withOpacity(0.7)
                                          : colorScheme.surfaceVariant
                                              .withOpacity(0.5),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        right: Radius.circular(7),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: cartItem.quantity! < book.stock
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Remove button
                          IconButton(
                            onPressed: onRemove,
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                              size: 22,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  colorScheme.errorContainer.withOpacity(0.2),
                              minimumSize: const Size(32, 32),
                              padding: EdgeInsets.zero,
                            ),
                            tooltip: 'Eliminar del carrito',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subtotal at bottom
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${(double.tryParse(book.precio) ?? 0) * cartItem.quantity!}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
