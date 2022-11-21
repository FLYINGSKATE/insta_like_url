import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(
    MaterialApp(
      title: 'Custom Named Routes Example',
      initialRoute: HomePage.route,
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
        routes: {
          '/': (context) => HomePage(),
          '/overview': (context) => OverviewPage(),
        }
    ),
  );
}

class Path {
  const Path(this.pattern, this.builder);

  /// A RegEx string for route matching.
  final String pattern;

  /// The builder for the associated pattern route. The first argument is the
  /// [BuildContext] and the second argument is a RegEx match if it is
  /// included inside of the pattern.
  final Widget Function(BuildContext, String) builder;
}

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      r'^' + r'/([\w-]+)$',
          (context, match) => Article.getArticlePage(match),
    ),
    Path(
      r'^' + OverviewPage.route,
          (context, match) => OverviewPage(),
    ),
    Path(
      r'^' + HomePage.route,
          (context, match) => HomePage(),
    ),
  ];

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    for (Path path in paths) {
      final regExpPattern = RegExp(path.pattern);
      if (regExpPattern.hasMatch(settings.name??"")) {
        final firstMatch = regExpPattern.firstMatch(settings.name??"");
        final match = (firstMatch?.groupCount == 1) ? firstMatch?.group(1) : null;
        return MaterialPageRoute<void>(
          builder: (context) => path.builder(context, match!),
          settings: settings,
        );
      }
    }

    // If no match was found, we let [WidgetsApp.onUnknownRoute] handle it.
    return MaterialPageRoute<void>(
      builder: (context) => HomePage(),
      settings: settings,
    );
  }
}

// In a real application this would probably be some kind of database interface.
const List<Article> articles = [
  Article(
    title: 'A very interesting article',
    slug: 'a-very-interesting-article',
  ),
  Article(
    title: 'Newsworthy news',
    slug: 'newsworthy-news',
  ),
  Article(
    title: 'RegEx is cool',
    slug: 'regex-is-cool',
  ),
];

class Article {
  const Article({required this.title, required this.slug});

  final String title;
  final String slug;

  static Widget getArticlePage(String slug) {
    for (Article article in articles) {
      if (article.slug == slug) {
        return ArticlePage(article: article);
      }
    }
    return UnknownArticle(userName: slug,);
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({Key? key, required this.article}) : super(key: key);

  static const String baseRoute = '/article';
  static String Function(String slug) routeFromSlug =
      (String slug) => baseRoute + '/$slug';

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(article.title),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}

class UnknownArticle extends StatelessWidget {

  final String userName;

  const UnknownArticle({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(userName+"Does Not Exsists"),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  static const String route = '/overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (Article article in articles)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ArticlePage.routeFromSlug(article.slug),
                  );
                },
                child: Text(article.title),
              ),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the home screen by popping the current route
                // off the stack.
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Overview page'),
          onPressed: () {
            // Navigate to the overview page using a named route.
            Navigator.pushNamed(context, OverviewPage.route);
          },
        ),
      ),
    );
  }
}
