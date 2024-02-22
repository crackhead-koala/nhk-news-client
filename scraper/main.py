from typing import List, Dict, Any

import json
import datetime
import zoneinfo
import argparse

import requests
import bs4
from bs4 import BeautifulSoup
import pocketbase
from tqdm.auto import tqdm


def get_article_list_from_nhk_website(
    cache: bool = True,
    cache_to: str = '../dump/top-list.json'
) -> List[Dict[str, Any]]:

    response = requests.get('https://www3.nhk.or.jp/news/easy/top-list.json')
    response.encoding = 'utf-8'
    top_list = response.json()

    for article in top_list:
        # convert time from JST to UTC (as string)
        article['news_prearranged_time'] = (
            datetime.datetime.strptime(
                article['news_prearranged_time'],
                '%Y-%m-%d %H:%M:%S'
            )
            .replace(tzinfo=zoneinfo.ZoneInfo('Japan'))
            .astimezone(zoneinfo.ZoneInfo('UTC'))
            .strftime('%Y-%m-%d %H:%M:%S')
        )

        # build URL
        article['news_url'] = \
            f"https://www3.nhk.or.jp/news/easy/{article['news_id']}/{article['news_id']}.html"

        # process article data
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

    if cache:
        with open(cache_to, 'w') as outfile:
            outfile.write(json.dumps(top_list))

    return top_list


def get_article_list_from_cache(cache_path: str = '../dump/top-list.json') -> List[Dict[str, Any]]:
    try:
        with open(cache_path, 'r') as infile:
            top_list = json.loads(infile.read())
    except Exception as e:
        raise e

    return top_list


def load_articles_to_pocketbase(
    pb_client: pocketbase.PocketBase,
    article_data: List[Dict[str, Any]]
) -> None:

    for article in tqdm(article_data):
        try:
            _ = pb_client.collection('top_list').create({
                'news_id': article['news_id'],
                'news_prearranged_time': article['news_prearranged_time'],
                'title': article['title'],
                'title_with_ruby': article['title_with_ruby'],
                'outline_with_ruby': article['outline_with_ruby'],
                'has_news_web_image': article['has_news_web_image'],
                'news_web_image_uri': article['news_web_image_uri'],
                'news_url': article['news_url'],
                'title_with_ruby_processed': article['title_with_ruby_processed']
            })
        except pocketbase.utils.ClientResponseError as e:
            raise Exception(
                f"Error creating record for article with news_id {article['news_id']}\n"
                f"Error: {e}\n"
                f"Article data: {article}"
            )
        except Exception as e:
            raise Exception(f'An unknown error occured: {e}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='NHK News Easy Article List Scraeper',
        description='Utility to scrape article data from the NHK website'
    )

    parser.add_argument(
        '-c', '--cache',
        action='store_true',
        help='prefer cached data to downloading it from the NHK website'
    )
    parser.add_argument(
        '-U', '--update-cache',
        action='store_true',
        help='update cached JSON data'
    )
    parser.add_argument('-H', '--pb-host', help='PocketBase host to use')
    parser.add_argument('-P', '--pb-port', help='PocketBase port to use')
    parser.add_argument('-u', '--pb-user', help='PocketBase admin user login')
    parser.add_argument('-p', '--pb-password', help='PocketBase admin user password')

    args = parser.parse_args()

    if args.cache:
        print('collecting data from cache')
        top_list = get_article_list_from_cache()
    else:
        print('collecting data from NHK website')
        top_list = get_article_list_from_nhk_website(args.update_cache or True)

    pb_client = pocketbase.PocketBase(f'http://{args.pb_host}:{args.pb_port}')
    pb_client.auth_store = pb_client.admins.auth_with_password(args.pb_user, args.pb_password)

    print('loading data to PocketBase')
    load_articles_to_pocketbase(pb_client, top_list)
