import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:exam1_software_movil/src/services/library_service.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';

class SpeechRecognitionService with ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final LibraryService _libraryService;
  final ShoppingCartProvider _cartProvider;
  bool _isInitialized = false;
  String _initError = '';
  bool _isDisposed = false;

  SpeechRecognitionService({
    required LibraryService libraryService,
    required ShoppingCartProvider cartProvider,
  })  : _libraryService = libraryService,
        _cartProvider = cartProvider {
    debugPrint('SpeechRecognitionService: Constructor llamado');
    _initSpeech();
  }

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isInitialized => _isInitialized;
  String get initError => _initError;

  void _safetlyNotifyListeners() {
    if (!_isDisposed) {
      try {
        notifyListeners();
      } catch (e) {
        debugPrint('SpeechRecognitionService: Error al notificar - $e');
      }
    }
  }

  /// Initialize speech recognition
  Future<void> _initSpeech() async {
    debugPrint('SpeechRecognitionService: Iniciando reconocimiento de voz');
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          if (_isDisposed) return;
          debugPrint('SpeechRecognitionService: Error - ${error.errorMsg}');
          _initError = 'Error de inicialización: ${error.errorMsg}';
          _safetlyNotifyListeners();
        },
        onStatus: (status) {
          if (_isDisposed) return;
          debugPrint('SpeechRecognitionService: Estado - $status');
        },
        debugLogging: true,
      );

      debugPrint(
          'SpeechRecognitionService: Inicialización completada, resultado: $_isInitialized');

      if (_isInitialized) {
        // Verificar idiomas disponibles
        final languages = await _speechToText.locales();
        debugPrint(
            'SpeechRecognitionService: Idiomas disponibles: ${languages.map((e) => "${e.localeId}(${e.name})").join(", ")}');
      } else {
        _initError = 'No se pudo inicializar el reconocimiento de voz';
      }
    } catch (e) {
      debugPrint('SpeechRecognitionService: Error en inicialización - $e');
      _isInitialized = false;
      _initError = 'Excepción: $e';
    }

    _safetlyNotifyListeners();
  }

  /// Start listening to voice input
  Future<bool> startListening() async {
    debugPrint(
        'SpeechRecognitionService: Intentando iniciar reconocimiento, isInitialized=$_isInitialized');

    if (_isDisposed) {
      debugPrint(
          'SpeechRecognitionService: No se puede iniciar porque el servicio fue desechado');
      return false;
    }

    await _stopListening();

    if (!_isInitialized) {
      debugPrint('SpeechRecognitionService: Reintentar inicialización');
      try {
        _isInitialized = await _speechToText.initialize(
          onStatus: (status) =>
              debugPrint('SpeechRecognitionService: Estado - $status'),
          onError: (error) =>
              debugPrint('SpeechRecognitionService: Error - ${error.errorMsg}'),
        );
        _safetlyNotifyListeners();
      } catch (e) {
        debugPrint('SpeechRecognitionService: Error al reiniciar - $e');
        return false;
      }
    }

    if (_isInitialized) {
      try {
        debugPrint('SpeechRecognitionService: Intentando escuchar...');
        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          listenMode: ListenMode.confirmation,
        );

        // Solo actualizar el estado después de verificar que comenzó la escucha
        _isListening = _speechToText.isListening;
        debugPrint(
            'SpeechRecognitionService: Estado de escucha: $_isListening');

        if (!_isListening) {
          _lastWords = 'No se pudo iniciar la escucha de voz';
        } else {
          _lastWords = 'Escuchando...';
        }

        _safetlyNotifyListeners();
        return _isListening;
      } catch (e) {
        debugPrint('SpeechRecognitionService: Error al iniciar escucha - $e');
        _isListening = false;
        _lastWords = 'Error: $e';
        _safetlyNotifyListeners();
        return false;
      }
    } else {
      debugPrint(
          'SpeechRecognitionService: No se pudo inicializar el reconocimiento');
      _lastWords = 'No se pudo inicializar el reconocimiento de voz';
      _safetlyNotifyListeners();
      return false;
    }
  }

  /// Stop listening to voice input
  Future<void> _stopListening() async {
    debugPrint(
        'SpeechRecognitionService: Deteniendo reconocimiento, isListening=${_speechToText.isListening}');
    if (_speechToText.isListening) {
      try {
        await _speechToText.stop();
        _isListening = false;
        _safetlyNotifyListeners();
      } catch (e) {
        debugPrint('SpeechRecognitionService: Error al detener escucha - $e');
      }
    }
  }

  /// Process speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (_isDisposed) return;

    debugPrint(
        'SpeechRecognitionService: Resultado recibido - ${result.recognizedWords} (final: ${result.finalResult})');
    _lastWords = result.recognizedWords;
    _safetlyNotifyListeners();

    if (result.finalResult) {
      _processVoiceCommand(_lastWords);
      _isListening = false;
      _safetlyNotifyListeners();
    }
  }

  /// Process the voice command to find and add books
  Future<void> _processVoiceCommand(String command) async {
    if (_isDisposed || command.isEmpty) return;

    debugPrint('SpeechRecognitionService: Procesando comando: $command');

    // Check if command contains keywords for adding to cart
    final addKeywords = [
      'añadir',
      'agregar',
      'comprar',
      'quiero',
      'carrito',
      'poner',
      'meter',
      'incluir'
    ];
    bool isAddCommand =
        addKeywords.any((keyword) => command.toLowerCase().contains(keyword));

    debugPrint(
        'SpeechRecognitionService: ¿Es comando de añadir? $isAddCommand');

    if (!isAddCommand) return;

    // Try to find the book in available books
    List<Book> books = _libraryService.books;
    debugPrint('SpeechRecognitionService: Libros disponibles: ${books.length}');

    // Almacena el libro con mejor coincidencia y su puntuación
    Book? matchedBook;
    double bestMatchScore = 0.0;

    // Normalizar el comando (quitar acentos, convertir a minúsculas)
    final normalizedCommand = _normalizeText(command.toLowerCase());
    debugPrint(
        'SpeechRecognitionService: Comando normalizado: $normalizedCommand');

    // 1. Primero, buscar coincidencias exactas
    for (Book book in books) {
      final normalizedBookName = _normalizeText(book.nombre.toLowerCase());

      if (normalizedCommand.contains(normalizedBookName)) {
        matchedBook = book;
        bestMatchScore = 1.0;
        debugPrint(
            'SpeechRecognitionService: Coincidencia exacta encontrada: ${book.nombre}');
        break;
      }
    }

    // 2. Si no hay coincidencia exacta, buscar coincidencias parciales
    if (matchedBook == null) {
      debugPrint('SpeechRecognitionService: Buscando coincidencias parciales');

      for (Book book in books) {
        final normalizedBookName = _normalizeText(book.nombre.toLowerCase());

        // Dividir en palabras
        final bookWords = normalizedBookName.split(' ');
        final commandWords = normalizedCommand.split(' ');

        // Puntuación basada en palabras coincidentes
        double matchScore = 0.0;
        int matchedWords = 0;

        // Verificar palabras significativas (más de 3 caracteres)
        for (String bookWord in bookWords) {
          if (bookWord.length > 3) {
            // Si la palabra del libro está contenida exactamente en el comando
            if (commandWords.contains(bookWord)) {
              matchScore += 1.0;
              matchedWords++;
            }
            // Si la palabra del libro está contenida como substring en el comando
            else if (normalizedCommand.contains(bookWord)) {
              matchScore += 0.8;
              matchedWords++;
            }
            // Si hay una similitud alta entre alguna palabra del comando y la palabra del libro
            else {
              for (String commandWord in commandWords) {
                if (commandWord.length > 3) {
                  double similarity =
                      _calculateSimilarity(bookWord, commandWord);
                  if (similarity > 0.7) {
                    // umbral de similitud
                    matchScore += similarity * 0.6;
                    matchedWords++;
                    break;
                  }
                }
              }
            }
          }
        }

        // Normalizar puntuación por la cantidad de palabras en el título del libro
        // para no favorecer libros con títulos más largos
        if (bookWords.length > 0 && matchedWords > 0) {
          double normalizedScore = matchScore / bookWords.length;

          // Mejorar la puntuación si encontramos múltiples palabras que coinciden
          if (matchedWords > 1) {
            normalizedScore *= (1.0 + (matchedWords / 10.0));
          }

          debugPrint(
              'SpeechRecognitionService: Libro: ${book.nombre} - Puntuación: $normalizedScore (matched words: $matchedWords)');

          // Actualizar el mejor resultado
          if (normalizedScore > bestMatchScore) {
            bestMatchScore = normalizedScore;
            matchedBook = book;
          }
        }
      }
    }

    // Un umbral mínimo para aceptar coincidencias
    final double MATCH_THRESHOLD = 0.15;

    // Add to cart if a book was found with suficiente puntuación
    if (matchedBook != null &&
        bestMatchScore >= MATCH_THRESHOLD &&
        matchedBook.stock > 0) {
      debugPrint(
          'SpeechRecognitionService: Añadiendo al carrito: ${matchedBook.nombre} (puntuación: $bestMatchScore)');
      try {
        await _cartProvider.addItemToCart(matchedBook, 1);

        // Reset last words
        _lastWords = 'Añadido al carrito: ${matchedBook.nombre}';
        _safetlyNotifyListeners();
      } catch (e) {
        debugPrint('SpeechRecognitionService: Error al añadir al carrito - $e');
        _lastWords = 'Error al añadir al carrito: $e';
        _safetlyNotifyListeners();
      }
    } else {
      debugPrint(
          'SpeechRecognitionService: No se encontró libro o no hay stock. Mejor puntuación: $bestMatchScore');
      _lastWords =
          'No se encontró el libro mencionado o no hay stock disponible';
      _safetlyNotifyListeners();
    }
  }

  /// Normaliza un texto quitando acentos y otros caracteres especiales
  String _normalizeText(String text) {
    // Mapeo de caracteres acentuados a no acentuados
    final Map<String, String> accentMap = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ä': 'a',
      'ë': 'e',
      'ï': 'i',
      'ö': 'o',
      'ü': 'u',
      'à': 'a',
      'è': 'e',
      'ì': 'i',
      'ò': 'o',
      'ù': 'u',
      'ñ': 'n',
    };

    // Reemplazar caracteres acentuados
    String normalized = text;
    accentMap.forEach((accent, normal) {
      normalized = normalized.replaceAll(accent, normal);
    });

    // Eliminar caracteres especiales y múltiples espacios
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }

  /// Calcula la similitud entre dos cadenas de texto
  /// Retorna un valor entre 0.0 (nada similar) y 1.0 (idéntico)
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Distancia de Levenshtein
    int distance = _levenshteinDistance(s1, s2);
    int maxLength = s1.length > s2.length ? s1.length : s2.length;

    return 1.0 - (distance / maxLength);
  }

  /// Calcula la distancia de Levenshtein entre dos cadenas
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  @override
  void dispose() {
    debugPrint('SpeechRecognitionService: Liberando recursos');
    _isDisposed = true;
    _stopListening();
    _speechToText.cancel();
    super.dispose();
  }
}
