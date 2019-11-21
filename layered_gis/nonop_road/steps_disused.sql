SELECT
5555 AS layer_code, 'nonop' AS layer_class, 'steps_disused' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM `openstreetmap-public-data-prod.osm_planet.features`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='proposed')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'proposed' AND tags.value='steps')

