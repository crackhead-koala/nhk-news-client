# import requests
import json
import bs4
from bs4 import BeautifulSoup


# response = requests.get(
#     'https://www3.nhk.or.jp/news/easy/top-list.json'
# )
# response.encoding = response.apparent_encoding

with open('dump/top-list.json', 'r') as in_:
    top_list = json.loads(in_.read())


for idx, article in enumerate(top_list):
    article['news_url'] = \
        f"https://www3.nhk.or.jp/news/easy/{article['news_id']}/{article['news_id']}.html"
    article['title_with_ruby_processed'] = []

    title_soup = BeautifulSoup(article['title_with_ruby'], 'html.parser')
    for el in title_soup:
        if isinstance(el, bs4.element.Tag):
            assert el.name == 'ruby'
            assert el.contents[1].name == 'rt'

            text = el.contents[0]
            ruby = el.contents[1].contents[0]

            article['title_with_ruby_processed'].append({'text': text, 'ruby': ruby})

        else:
            el_chunks = el.split('\u3000')
            for chunk in el_chunks:
                article['title_with_ruby_processed'].append({'text': chunk, 'ruby': None})


with open('dump/top-list-processed.json', 'w') as out:
    out.write(json.dumps(top_list, indent=2))
