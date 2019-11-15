SELECT
  6109 AS layer_code, 'railway' AS layer_class, 'rack' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM `openstreetmap-public-data-prod.osm_planet.features`
  WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rack')
OR (
  EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rail')
  AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'traction' AND tags.value = 'rack')
)
OR (
  EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rail')
  AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'rack' AND tags.value = 'yes')
)
