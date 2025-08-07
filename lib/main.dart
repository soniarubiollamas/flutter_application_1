import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // al usar super, se pasa el valor directamente al constructor de la clase padre

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'flutter_application_1',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 131, 238)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // ↓ Add this.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // list de favoritos
  // var favorites = <WordPair> []; // inicializar con lista vacía
  var favorites = <WordPair>{}; // conjunto de favoritos

  
  void toggleFavorite(){ // que quita el par actual de palabras de la lista (si ya está en ella) o lo agrega a ella (si aún no está allí)
    if (favorites.contains(current)){
      favorites.remove(current);
    } else{
      favorites.add(current); // add para añadir a vector 
    }
    notifyListeners();
  }
  
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


// Esta clase extiende State y, por lo tanto, puede administrar sus propios valores (puede cambiarse a sí misma)
// _ porque es privada
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }



    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea( // SafeArea garantiza que los elementos secundarios no se muestren oscurecidos por un recorte de hardware o una barra de estado
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // false o true depende de si queremos que se vea expandida la barra de tareas o no.  Muestra las etiquetas junto a los íconos.
                  //  con los constraints app responde a su entorno, como el tamaño de la pantalla, la orientación y la plataforma.
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex, // selecciona el primer destino. Si se cambia a 1, cambiará (hard-coded  = 0)
                  onDestinationSelected: (value) {
                    // ↓ Replace print with this.
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current; // no nos interesa luego crear un widget que afecte a app.State, sino solo a la palabra, por eso mejor crear una variable

    IconData icon;

    if (appState.favorites.contains(pair)){
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    
      // todos los elementos de debajo son parte de una columna
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('Ayuda:'),
            BigCard(pair: pair),
            SizedBox(height: 20), // para agregar espacio visual entre la tarjeta y el botón. Solo ocupa espacio, no renderiza nada por sí solo
            
            // para que haya dos elevatedButtons seguidos (en serie), se envuelve (wrap) en un widget de row
            // por defecto, actúa como Column y agrupa sus elemntos secundarios a la izquierda (column lo hace en la parte de arriba)
            Row(
              mainAxisSize: MainAxisSize.min, // para que ocupe lo mínimo horizontalmente (dentro de estar en el centro porque está wrappeado por un body: center)

              children: [
                // botón 1
                ElevatedButton.icon( // crea un botón con un estilo elevado. Es un widget
                  onPressed: () {
                    // print('button pressed!');
                    appState.toggleFavorite(); 
                  },
                  icon: Icon(icon),
                  // label y no child
                  label: Text('favorite'),
                ),
                SizedBox(height: 20),
                 ElevatedButton( // crea un botón con un estilo elevado. Es un widget
                  onPressed: () {
                    // print('button pressed!');
                    appState.getNext();  // ← This instead of print().
                        
                  },
                  // child y no children porque solo tiene un widget
                  child: Text('next'),
                ),


              ],
            ),
          ],
        ),
      );
    
  }
}

// Widget para trabajar con el texto que se ve
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context); // el código solicita el tema actual de la app 
        final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold,
        // con theme.textTheme se accede al tema de la fuente de la app
        // displayMedium sirve para texto corto e importante. Como podría ser null, poner ! detrás implica decirle a dart que estoy segura de que no es nulo
        // copyWith copia el tema, y se especifica que lo hace con el color del tema wue se le ha dado
        );
    return Card(
      color: theme.colorScheme.inversePrimary,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style:style, 
          semanticsLabel:"${pair.first} ${pair.second}"),
    ),
    );
  }
}


// ...

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