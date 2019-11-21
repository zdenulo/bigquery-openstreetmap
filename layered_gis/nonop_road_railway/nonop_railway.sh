#!/bin/sh

NONOP_TYPES=("62:proposed" "63:construction" "64:disused" "65:abandoned")
LAYER=(
        "6102:railway=light_rail"
        "6103:railway=subway"
        "6104:railway=tram"
        "6105:railway=monorail"
        "6106:railway=narrow_gauge"
        "6107:railway=miniature"
        "6111:railway=drag_lift"
        "6112:aerialway=chair_lift"
        "6113:railway=cable_car"
        "6114:railway=gondola"
        "6115:railway=goods"

)

for nonop_data in "${NONOP_TYPES[@]}"
do
  PREFIX="${nonop_data%%:*}"
  NONOP_TYPE="${nonop_data##*:}"
  for layer in "${LAYER[@]}"
  do
    CODE_TEMP="${layer%%:*}"
    KV="${layer##*:}"
    CODE="${PREFIX}${CODE_TEMP}"
    K="${KV%%=*}"
    V="${KV##*=}"
    echo "SELECT $CODE AS layer_code, 'nonop' AS layer_class, '${V}_${nonop_type}' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
    FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
    WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = '$K' AND tags.value='proposed')
    AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'proposed' AND tags.value='$V')
    " > "${V}_${nonop_type}.sql"
done
done

echo "SELECT
  6101 AS layer_code, 'railway' AS layer_class, 'rail' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value='rail')
AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'traction')" > "rail.sql"

echo "SELECT
  6108 AS layer_code, 'railway' AS layer_class, 'funicular' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'funicular')
OR (
EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rail')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'traction' AND tags.value = 'funicular')
)" > "funicilar.sql"

echo "SELECT
  6109 AS layer_code, 'railway' AS layer_class, 'rack' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
  WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rack')
OR (
  EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rail')
  AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'traction' AND tags.value = 'rack')
)
OR (
  EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'railway' AND tags.value = 'rail')
  AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'rack' AND tags.value = 'yes')
)" > "rack.sql"

echo "SELECT
  6119 AS layer_code, 'railway' AS layer_class, 'other_lift' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
  WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'aerialway' AND tags.value IN ('platter', 't-bar', 'j-bar', 'magic_carpet', 'zip_line', 'rope_tow', 'mixed_lift'))
  " > "other_lift.sql"