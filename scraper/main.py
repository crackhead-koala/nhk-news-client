import requests


if __name__ == '__main__':
    response_list = requests.get('https://www3.nhk.or.jp/news/easy/news-list.json')
    response_list.encoding = 'utf-8'

    data = response_list.json()
