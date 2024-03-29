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
    const String appTitle = 'Random Generate Word App';
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: appTitle,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.pink), // Mengganti warna
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Variabel kata saat ini
  var history = <WordPair>[]; // Variabel history kata

  GlobalKey? historyListKey;

  // ↓ Memunculkan kata baru beserta history
  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[]; // Variabel kata favorit

  // ↓ Action favorite kata
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      // ↓ Menghilangkan tanda favorite kata
      favorites.remove([pair]);
    } else {
      // ↓ Memuncul tanda favorite kata
      favorites.add(pair);
    }
    notifyListeners();
  }

  // ↓ Action menghapus favorite kata
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

// ↓ Class untuk halaman generator word
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Membuat variabel selectedIndex

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Beralih ke halaman generator (Home)
      case 1:
        page = FavoritesPage(); // Beralih ke halaman favorites
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,

      // ↓ Animasi tiap ganti kata
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home), // Material icon home
                        label: 'Home', // Label Halaman Home
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite), // Material icon favorites
                        label: 'Favorites', // Label Halaman Favorites
                      ),
                    ],
                    currentIndex:
                        selectedIndex, // Koneksi ke variabel selectedIndex
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value; // Memposisikan ke selectedIndex
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended:
                        constraints.maxWidth >= 600, // Atur lebar responsive
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home), // Material icon home
                        label: Text('Home'), // Label Halaman Home
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite), // Material icon favorites
                        label: Text('Favorites'), // Label Halaman Favorites
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
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

// Widget gambar
class ImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizedBox(width: 40);
    return Image.asset(
      'images/utdi.png',
      width: 150,
      height: 150,
    );
  }
}

// Widget text
class TextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '215411037',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Isa Anggie Alfianto',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ↓ Class untuk memunculkan history kata
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  // Untuk fade out history
  static const Gradient _maskingGradient = LinearGradient(
    // Gradiasi warna history
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('Kamu punya '
              '${appState.favorites.length} kata favorit:'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
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
      icon = Icons.favorite; // Material icon favorites nyala
    } else {
      icon = Icons.favorite_border; // Material icon favorites mati
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Merubah posisi ke center
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 30), // Buat gaps antara history dan current word
          BigCard(pair: pair), // Membuat class BigCard
          SizedBox(height: 10), // Buat gaps antara widget BigCard dan Button
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
              SizedBox(width: 10), // Gaps antar tombol
              ElevatedButton.icon(
                onPressed: () {
                  appState.getNext(); // ← Koneksi ke MyAppState
                },
                icon: Icon(icon = Icons.arrow_forward),
                label: Text('Next'),
              ),
            ],
          ),
          SizedBox(height: 20), // Spacer
          Row(
            children: [
              // Image widget
              Expanded(
                flex: 1,
                child: ImageWidget(),
              ),
              // Text widget
              Expanded(
                flex: 1,
                child: TextWidget(),
              ),
            ],
          ),
          SizedBox(height: 20), // Spacer
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context); // Menambah tema
    // ↓ Gaya tema
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary, // Memberi warna
      child: Padding(
        padding: const EdgeInsets.all(20), // Ukuran padding
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
