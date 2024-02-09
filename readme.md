# NHK News Client

A simple mobile client for the [NHK News Easy](https://www3.nhk.or.jp/news/easy/) website.

## Plan

1. backend:
   - scraper collects data into a database (Python)
   - HTTP API to request the news data (Go)
2. frontend v0.0.1:
   - get news from API, show them in a list, each news article has a page (Dart+Flutter)
   - must have furigana readings!
3. frontend 0.1.0:
   - integrate a dictionary, show definitions in a popup for selected words (how tho?)

## Notes

- NHK has all its Easy News in one giant JSON:
  - news separated by date: `https://www3.nhk.or.jp/news/easy/news-list.json`; example:

  ```json
  [
    {
      "2024-02-09": [
        {
          "top_priority_number": 1,
          "news_prearranged_time": "2024-02-09 15:45:00",
          "news_id":"k10014352591000",
          "title":"能登半島地震　外国人のための相談会",
          // <...>
        }
      ]
    }
  ]
  ```

  - all news in one list, ordered with the most recent article first: `https://www3.nhk.or.jp/news/easy/top-list.json`; example:

  ```json
  [
    {
      "top_priority_number": 1,
      "news_id": "k10014352591000",
      "top_display_flag": true,
      "news_prearranged_time": "2024-02-09 15:45:00",
      "title": "能登半島地震　外国人のための相談会",
      // <..>
    }
  ]
  ```
