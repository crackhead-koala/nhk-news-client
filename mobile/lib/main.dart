import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nhk_news_easy_client/mock_data.dart';

void main() => runApp(const App());

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

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    List<dynamic> newsArticleData = jsonData;

    List<Widget> articleCards = [];
    for (Map articleData in newsArticleData) {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        // mainAxisAlignment: MainAxisAlignment.start,
        children: articleCards,
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
