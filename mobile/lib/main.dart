import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pocketbase/pocketbase.dart';

final pbClient = PocketBase('http://0.0.0.0:8090');

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //   useMaterial3: true,
      // ),
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const HomePage(title: 'NHK News Easy'),
    );
  }
}

List<NHKArticleCard> buildArticleDataList(
    ResultList<RecordModel> newsArticleData) {
  final List<Map<String, dynamic>> newsArticleDataJson =
      newsArticleData.toJson()['items'];
  List<NHKArticleCard> articleCards = [];

  for (Map articleData in newsArticleDataJson) {
    List<RubyTextData> articleTitleData = [];

    for (Map textChunk in articleData['title_with_ruby_processed']) {
      if (textChunk['ruby'] != null) {
        articleTitleData.add(
          RubyTextData(textChunk['text'], ruby: textChunk['ruby']),
        );
      } else {
        List<String> glyphs = textChunk['text'].split('');
        for (String glyph in glyphs) {
          articleTitleData.add(
            RubyTextData(glyph),
          );
        }
      }
    }

    articleCards.add(
      NHKArticleCard(
        titleData: articleTitleData,
        dateString: articleData['news_prearranged_time'],
        articleURL: articleData['news_url'],
        articleImageURL: articleData['has_news_web_image']
            ? articleData['news_web_image_uri']
            : null,
      ),
    );
  }

  return articleCards;
}

Future<ResultList<RecordModel>> getPaginatedArticleData({
  int page = 1,
  int perPage = 30,
  bool skipTotal = false,
  String? expand,
  String? filter,
  String? sort,
  String? fields,
  Map<String, dynamic> query = const {},
  Map<String, String> headers = const {},
}) async {
  await pbClient.admins.authWithPassword('app@mail.com', 'qwerty8000');
  final data = await pbClient.collection('top_list').getList(
        page: page,
        perPage: perPage,
        skipTotal: skipTotal,
        expand: expand,
        filter: filter,
        sort: sort,
        fields: fields,
        query: query,
        headers: headers,
      );
  return data;
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 1;
  bool _isLoadingArticles = false;
  List<NHKArticleCard> loadedArticleCards = [];

  void incrementCurrentPage() {
    setState(() {
      _currentPage++;
    });
  }

  void setLoadingStateStart() {
    setState(() {
      _isLoadingArticles = true;
    });
  }

  void setLoadingStateFinish() {
    setState(() {
      _isLoadingArticles = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setLoadingStateStart();
    loadNextArticlePage();
  }

  void loadNextArticlePage() {
    setState(() {
      setLoadingStateStart();
      getPaginatedArticleData(page: _currentPage, perPage: 10).then(
        (articleData) {
          final newArticleCards = buildArticleDataList(articleData);
          for (final articleCard in newArticleCards) {
            loadedArticleCards.add(articleCard);
          }
          setLoadingStateFinish();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoadingArticles && _currentPage == 1
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: loadedArticleCards.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == loadedArticleCards.length) {
                  return TextButton(
                    onPressed: () {
                      incrementCurrentPage();
                      loadNextArticlePage();
                    },
                    child: const Text('Load more'),
                  );
                }
                return loadedArticleCards[index];
              },
            ),
    );
  }
}

class NHKArticleCard extends StatefulWidget {
  final List<RubyTextData> titleData;
  final String dateString;
  final String articleURL;
  final String? articleImageURL;

  const NHKArticleCard({
    super.key,
    required this.titleData,
    required this.dateString,
    required this.articleURL,
    this.articleImageURL,
  });

  @override
  State<NHKArticleCard> createState() => _NHKArticleCardState();
}

class _NHKArticleCardState extends State<NHKArticleCard> {
  bool _isCollapsed = true;

  void toggleCollapsedState() {
    setState(() {
      if (_isCollapsed) {
        _isCollapsed = false;
      } else {
        _isCollapsed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          try {
            openURLInBrowser(widget.articleURL);
          } catch (e) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Could not open browser.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          }
        },
        // child: SelectionArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  widget.articleImageURL != null
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          child: Image.network(
                            widget.articleImageURL!,
                            width: _isCollapsed
                                ? screenWidth * 0.3
                                : screenWidth - 56.0,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                          ),
                          width: _isCollapsed
                              ? screenWidth * 0.3
                              : screenWidth - 56.0,
                          height: _isCollapsed
                              ? screenWidth * 0.3 / 16.0 * 9.0
                              : (screenWidth - 56.0) / 16.0 * 9.0,
                          child: const Center(
                            child: Icon(Icons.article),
                          ),
                        ),
                  _isCollapsed
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            isoDateTimeToJapanese(widget.dateString),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            _isCollapsed
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    child: Text(
                      isoDateTimeToJapanese(
                        widget.dateString,
                        singleLine: true,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: RubyText(
                  widget.titleData,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: _isCollapsed
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                ),
                trailing: IconButton(
                  icon: Icon(
                    _isCollapsed ? Icons.expand_more : Icons.expand_less,
                  ),
                  onPressed: () => toggleCollapsedState(),
                ),
              ),
            ),
          ],
        ),
        // ),
      ),
    );
  }
}

String isoDateTimeToJapanese(String isoDateTime, {bool singleLine = false}) {
  // 2024年2月16日 (金) 16時00分
  final DateTime dateDime = DateTime.parse(isoDateTime);

  final String weekdayJapanese = switch (dateDime.weekday) {
    DateTime.sunday => '日',
    DateTime.monday => '月',
    DateTime.tuesday => '火',
    DateTime.wednesday => '水',
    DateTime.thursday => '木',
    DateTime.friday => '金',
    DateTime.saturday => '土',
    _ => throw Exception('This is unreachable')
  };

  final DateFormat formatter = DateFormat(
    'yyyy年MM月dd日 ($weekdayJapanese)${singleLine ? ' ' : '\n'}HH時mm分',
  );

  return formatter.format(dateDime);
}

// TODO: use web view inside bottom sheet
// https://medium.com/@tsung-wei_hsu/flutter-how-to-build-draggable-bottom-sheet-like-google-maps-1165f5b07366
void openURLInBrowser(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } catch (e) {
    throw Exception('Could not open URL: $url: $e');
  }
}
