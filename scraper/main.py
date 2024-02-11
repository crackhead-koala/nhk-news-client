import requests
from bs4 import BeautifulSoup


response = requests.get(
    'https://www3.nhk.or.jp/news/easy/k10014352591000/k10014352591000.html'
)
response.encoding = 'utf-8'

page_data = BeautifulSoup(response.content, 'html.parser')
print(page_data.find('div', {'id': 'js-article-body'}))
