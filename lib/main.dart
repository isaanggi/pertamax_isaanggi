import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.green), // Mengganti warna
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // ↓ Memunculkan kata baru
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  // ↓ Memfavorit kata
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ↓ Class yang muncul ketika StatefulWidget
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Membuat variabel selectedIndex
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Beralih ke halaman generator (Home)
        break;
      case 1:
        page = FavoritesPage(); // Beralih ke halaman favorites
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600, // Atur lebar responsive
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home), // Material icon home
                    label: Text('Home'), // Halaman Home
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite), // Material icon favorites
                    label: Text('Favorites'), // Halaman Favorites
                  ),
                ],
                selectedIndex:
                    selectedIndex, // Koneksi ke variabel selectedIndex
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value; // Memposisikan ke selectedIndex
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // ← Halaman baru
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // ↓ Menambah icon
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; // Material icon favorites
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Merubah posisi ke center
        children: [
          BigCard(pair: pair), // Membuat class BigCard
          SizedBox(height: 30), // Buat gaps antara widget BigCard dan Button
          // ↓ Menambah tombol
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ↓ Tombol Like dengan icon
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // ← Koneksi ke MyAppState
                },
                icon: Icon(icon), // ← Koneksi ke icon
                label: Text('Like'),
              ),
              SizedBox(width: 30), // Gaps antar tombol
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // ← Koneksi ke MyAppState
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Menambah tema
    // ↓ Gaya tema
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary, // Memberi warna
      child: Padding(
        padding: const EdgeInsets.all(20), // Ukuran padding
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}", // Override visual
        ),
      ),
    );
  }
}
