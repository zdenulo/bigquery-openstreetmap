SELECT
  *
FROM `openstreetmap-public-data-dev.osm_planet.points`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'shop' AND tags.value='hardware')
UNION ALL
SELECT
  *
FROM `openstreetmap-public-data-dev.osm_planet.multipolygons`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'shop' AND tags.value='hardware')
UNION ALL
SELECT
  *
FROM `openstreetmap-public-data-dev.osm_planet.other_relations`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'shop' AND tags.value='hardware')

