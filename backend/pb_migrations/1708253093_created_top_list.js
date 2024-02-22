/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "ssbxpitfhuyp70v",
    "created": "2024-02-18 10:44:53.607Z",
    "updated": "2024-02-18 10:44:53.607Z",
    "name": "top_list",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "xmgmrdju",
        "name": "news_id",
        "type": "text",
        "required": true,
        "presentable": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": "^k\\d{14}$"
        }
      },
      {
        "system": false,
        "id": "yq5n0d72",
        "name": "news_prearranged_time",
        "type": "date",
        "required": true,
        "presentable": true,
        "unique": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "system": false,
        "id": "04f8531b",
        "name": "title",
        "type": "text",
        "required": true,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "kiqemmqf",
        "name": "title_with_ruby",
        "type": "text",
        "required": true,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "a3b6jqkt",
        "name": "outline_with_ruby",
        "type": "text",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "rzn5hqlz",
        "name": "has_news_web_image",
        "type": "bool",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "gnseep5q",
        "name": "news_web_image_uri",
        "type": "url",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "exceptDomains": [],
          "onlyDomains": []
        }
      },
      {
        "system": false,
        "id": "2rmektqc",
        "name": "news_url",
        "type": "url",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "exceptDomains": [],
          "onlyDomains": []
        }
      },
      {
        "system": false,
        "id": "ap2h1qfo",
        "name": "title_with_ruby_processed",
        "type": "json",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "maxSize": 2000000
        }
      }
    ],
    "indexes": [
      "CREATE INDEX `idx_3Pcd3PH` ON `top_list` (`news_id`)",
      "CREATE INDEX `idx_uQA5myB` ON `top_list` (`news_prearranged_time`)"
    ],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("ssbxpitfhuyp70v");

  return dao.deleteCollection(collection);
})
