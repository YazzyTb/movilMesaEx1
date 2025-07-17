import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/models/category_model.dart';
import 'package:exam1_software_movil/src/services/library_service.dart';
import 'package:exam1_software_movil/src/services/category_service.dart';
import 'package:exam1_software_movil/src/services/speech_recognition_service.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/widgets/book_card.dart';
import 'package:exam1_software_movil/src/pages/loading_page.dart';
import 'package:exam1_software_movil/src/widgets/custom_gradient_background.dart';
import 'package:exam1_software_movil/src/widgets/nova_logo.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  String _searchQuery = '';
  int? _selectedCategoryId;
  TextEditingController _searchController = TextEditingController();
  late SpeechRecognitionService _speechRecognitionService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize providers if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryService>(context, listen: false).loadCategories();
      _initializeSpeechService();
    });
  }

  void _initializeSpeechService() {
    debugPrint('BooksPage: Inicializando servicio de reconocimiento de voz');
    try {
      final libraryService =
          Provider.of<LibraryService>(context, listen: false);
      final cartProvider =
          Provider.of<ShoppingCartProvider>(context, listen: false);

      _speechRecognitionService = SpeechRecognitionService(
        libraryService: libraryService,
        cartProvider: cartProvider,
      );

      // Escuchar cambios en el servicio
      _speechRecognitionService.addListener(() {
        if (mounted) {
          setState(() {
            // Actualizar UI cuando cambie el estado
            _isInitialized = _speechRecognitionService.isInitialized;
          });
        }
      });

      // Marcar como inicializado para mostrar los botones
      setState(() {
        _isInitialized = true;
      });

      debugPrint('BooksPage: Servicio de reconocimiento de voz inicializado');
    } catch (e) {
      debugPrint(
          'BooksPage: Error al inicializar servicio de reconocimiento: $e');
      // No hacer nada, los botones de reconocimiento seguirán inhabilitados
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_isInitialized) {
      _speechRecognitionService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryService = Provider.of<LibraryService>(context);
    final categoryService = Provider.of<CategoryService>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Filter books by search query and selected category
    List<Book> filteredBooks = libraryService.books.where((book) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          book.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.descripcion.toLowerCase().contains(_searchQuery.toLowerCase());

      // Debug category information
      if (_selectedCategoryId != null) {
        print('Selected category ID: $_selectedCategoryId');
        print(
            'Book ${book.id} - Category: ${book.categoria?.id ?? 'null'}, Name: ${book.categoria?.nombre ?? 'null'}');
      }

      // Filter by category
      final matchesCategory = _selectedCategoryId == null ||
          (book.categoria != null && book.categoria!.id == _selectedCategoryId);

      if (_selectedCategoryId != null) {
        print('Book ${book.id} matches category: $matchesCategory');
      }

      return matchesSearch && matchesCategory;
    }).toList();

    // Show loading indicator while fetching data
    if (libraryService.isLoading) {
      return const LoadingPage();
    }

    // Show error if there's an issue fetching books
    if (libraryService.hasError) {
      return _ErrorView(
        errorMessage: libraryService.errorMessage,
        onRetry: () => libraryService.refreshBooks(),
      );
    }

    // Show empty state if no books are available
    if (libraryService.books.isEmpty) {
      return _EmptyBooksView(onRefresh: () => libraryService.refreshBooks());
    }

    // Show books in a grid view
    return CustomGradientBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Voice recognition button
            FloatingActionButton(
              heroTag: "voiceRecognitionBtn",
              onPressed: () {
                _startVoiceRecognition();
              },
              backgroundColor: colorScheme.secondary,
              child: Icon(
                _isInitialized && _speechRecognitionService.isListening
                    ? Icons.mic
                    : Icons.mic_none,
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Refresh button
            FloatingActionButton(
              heroTag: "refreshBooksBtn",
              onPressed: () => libraryService.refreshBooks(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.refresh, color: colorScheme.onPrimary),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NovaLogo(
                      size: 32,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    Text(
                      "Catálogo",
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    const SizedBox(width: 32), // Balance the logo
                  ],
                ),
              ),

              // Search bar with voice button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar libros...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear,
                                        color: colorScheme.primary),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      // Voice search button
                      IconButton(
                        icon: Icon(
                          _isInitialized &&
                                  _speechRecognitionService.isListening
                              ? Icons.mic
                              : Icons.mic_none,
                          color: _isInitialized &&
                                  _speechRecognitionService.isListening
                              ? colorScheme.secondary
                              : colorScheme.primary,
                        ),
                        onPressed: _startVoiceRecognition,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              // Voice recognition status
              if (_isInitialized &&
                  _speechRecognitionService.lastWords.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.record_voice_over,
                          color: colorScheme.onSecondaryContainer,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _speechRecognitionService.lastWords,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: colorScheme.onSecondaryContainer,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              // This will trigger a rebuild
                            });
                          },
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

              // Category chips
              categoryService.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // "All" category
                            _buildCategoryChip(
                              context: context,
                              label: 'Todos',
                              isSelected: _selectedCategoryId == null,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategoryId = null;
                                });
                              },
                            ),
                            // Dynamic categories
                            ...categoryService.categories
                                .where((category) => category.isActive)
                                .map((category) => _buildCategoryChip(
                                      context: context,
                                      label: category.nombre,
                                      isSelected:
                                          _selectedCategoryId == category.id,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedCategoryId = category.id;
                                        });
                                      },
                                    )),
                          ],
                        ),
                      ),
                    ),

              // Books grid
              Expanded(
                child: filteredBooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron libros',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otra búsqueda o categoría',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: RefreshIndicator(
                          onRefresh: () async => libraryService.refreshBooks(),
                          child: MasonryGridView.builder(
                            itemCount: filteredBooks.length,
                            gridDelegate:
                                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            itemBuilder: (context, index) {
                              return BookCard(book: filteredBooks[index]);
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startVoiceRecognition() async {
    if (!_isInitialized) {
      debugPrint(
          'BooksPage: No se puede iniciar el reconocimiento, servicio no inicializado');
      _showErrorDialog(
          'El servicio de reconocimiento de voz no está disponible');
      return;
    }

    debugPrint('BooksPage: Iniciando reconocimiento de voz');

    // Iniciar el reconocimiento de voz
    bool success = await _speechRecognitionService.startListening();

    // Si no se pudo iniciar el reconocimiento, mostrar un error
    if (!success) {
      if (!context.mounted) return;
      _showErrorDialog('No se pudo iniciar el reconocimiento de voz');
      return;
    }

    // Mostrar diálogo con feedback en tiempo real
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _VoiceRecognitionDialog(
        speechRecognitionService: _speechRecognitionService,
      ),
    ).then((_) {
      // Al cerrar el diálogo, actualizar la interfaz
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de reconocimiento de voz'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required void Function(bool)? onSelected,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Diálogo para mostrar el estado del reconocimiento de voz
class _VoiceRecognitionDialog extends StatefulWidget {
  final SpeechRecognitionService speechRecognitionService;

  const _VoiceRecognitionDialog({
    required this.speechRecognitionService,
  });

  @override
  State<_VoiceRecognitionDialog> createState() =>
      _VoiceRecognitionDialogState();
}

class _VoiceRecognitionDialogState extends State<_VoiceRecognitionDialog> {
  late SpeechRecognitionService _service;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _service = widget.speechRecognitionService;

    try {
      _service.addListener(_refresh);

      // Auto-cerrar el diálogo después de cierto tiempo de inactividad
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && !_closed) {
          _closed = true;
          Navigator.of(context).pop();
        }
      });

      debugPrint(
          'VoiceRecognitionDialog: Diálogo iniciado, isListening=${_service.isListening}');
    } catch (e) {
      debugPrint('VoiceRecognitionDialog: Error al inicializar - $e');
      // Cerrar el diálogo si hay un error
      Future.microtask(() {
        if (mounted && !_closed) {
          _closed = true;
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    try {
      _service.removeListener(_refresh);
    } catch (e) {
      debugPrint('VoiceRecognitionDialog: Error al remover listener - $e');
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted && !_closed) {
      try {
        setState(() {});

        // Auto-cerrar el diálogo cuando se ha procesado el comando exitosamente
        if (_service.lastWords.startsWith('Añadido al carrito:')) {
          _closed = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        debugPrint('VoiceRecognitionDialog: Error en refresh - $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reconocimiento de voz',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(colorScheme),
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusIconColor(colorScheme),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getStatusText(),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              _getMessageText(),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _closed = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
                if (_service.isInitialized && !_service.isListening)
                  TextButton(
                    onPressed: () {
                      _service.startListening();
                    },
                    child: const Text('Intentar de nuevo'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    if (!_service.isInitialized) {
      return colorScheme.error.withOpacity(0.2);
    }

    if (_service.isListening) {
      return colorScheme.primary.withOpacity(0.2);
    }

    if (_service.lastWords.startsWith('Añadido al carrito:')) {
      return colorScheme.secondary.withOpacity(0.2);
    }

    if (_service.lastWords.startsWith('No se encontró')) {
      return colorScheme.error.withOpacity(0.2);
    }

    return colorScheme.surfaceVariant;
  }

  Color _getStatusIconColor(ColorScheme colorScheme) {
    if (!_service.isInitialized) {
      return colorScheme.error;
    }

    if (_service.isListening) {
      return colorScheme.primary;
    }

    if (_service.lastWords.startsWith('Añadido al carrito:')) {
      return colorScheme.secondary;
    }

    if (_service.lastWords.startsWith('No se encontró')) {
      return colorScheme.error;
    }

    return colorScheme.onSurfaceVariant;
  }

  IconData _getStatusIcon() {
    if (!_service.isInitialized) {
      return Icons.error_outline;
    }

    if (_service.isListening) {
      return Icons.mic;
    }

    if (_service.lastWords.startsWith('Añadido al carrito:')) {
      return Icons.check_circle_outline;
    }

    if (_service.lastWords.startsWith('No se encontró')) {
      return Icons.highlight_off;
    }

    return Icons.mic_off;
  }

  String _getStatusText() {
    if (!_service.isInitialized) {
      return 'Error de inicialización';
    }

    if (_service.isListening) {
      return 'Escuchando...';
    }

    if (_service.lastWords.startsWith('Añadido al carrito:')) {
      return '¡Producto añadido!';
    }

    if (_service.lastWords.startsWith('No se encontró')) {
      return 'Producto no encontrado';
    }

    return 'Procesando...';
  }

  String _getMessageText() {
    if (!_service.isInitialized) {
      return _service.initError.isNotEmpty
          ? _service.initError
          : 'No se pudo inicializar el reconocimiento de voz';
    }

    if (_service.lastWords.isEmpty) {
      return 'Diga el nombre del libro que desea agregar al carrito';
    }

    return _service.lastWords;
  }
}

class _ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomGradientBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NovaLogo(
                    size: 48,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los libros',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBooksView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyBooksView({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomGradientBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NovaLogo(
                    size: 48,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  Icon(
                    Icons.auto_stories_rounded,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay libros disponibles',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se encontraron libros en nuestro catálogo',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
