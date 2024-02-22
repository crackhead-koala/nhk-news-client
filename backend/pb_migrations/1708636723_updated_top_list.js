/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("ssbxpitfhuyp70v")

  // update
  collection.schema.addField(new SchemaField({
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
      "pattern": "^(k|em)\\d{13,14}$"
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("ssbxpitfhuyp70v")

  // update
  collection.schema.addField(new SchemaField({
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
      "pattern": "^(k|en)\\d{13,14}$"
    }
  }))

  return dao.saveCollection(collection)
})
