#!/bin/sh

LAYER=(
        "5111:highway=motorway"
        "5112:highway=trunk"
        "5113:highway=primary"
        "5114:highway=secondary"
        "5115:highway=tertiary"
        "5121:highway=unclassified"
        "5122:highway=residental"
        "5123:highway=living_street"
        "5124:highway=pedestrian"
        "5131:highway=motorway_link"
        "5132:highway=trunk_link"
        "5133:highway=primary_link"
        "5134:highway=secondary_link"
        "5141:highway=service"
        "5142:highway=track"
        "5155:highway=steps"
        "5160:route=ferry"
        "5199:highway=road"

)

for layer in "${LAYER[@]}"
do
  CODE="${layer%%:*}"
  KV="${layer##*:}"
  K="${KV%%=*}"
  V="${KV##*=}"
echo "SELECT
  $CODE AS layer_code, 'road' AS layer_class, '$V' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = '$K' AND tags.value='$V')" > "$V.sql"
done


LAYER=(
        "5143:track_grade1:tracktype=grade1"
        "5144:track_grade2:tracktype=grade2"
        "5145:track_grade3:tracktype=grade3"
        "5146:track_grade4:tracktype=grade4"
        "5147:track_grade5:tracktype=grade5"
)


for layer in "${LAYER[@]}"
do
  CODE="${layer%%:*}"
  KV="${layer##*:}"
  T="${layer#*:}"
  C="${T%%:*}"
  KV="${T##*:}"
  K="${KV%%=*}"
  V="${KV##*=}"

  echo "SELECT
  $CODE AS layer_code, 'road' AS layer_class, '$C' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='track')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = '$K' AND tags.value='$V')" > "$C.sql"
done

echo "SELECT
  5151 AS layer_code, 'road' AS layer_class, 'bridleway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM  \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='bridleway')
OR (
EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'horse' AND tags.value='designated')
)" > "bridleway.sql"

echo "SELECT
  5152 AS layer_code, 'road' AS layer_class, 'cycleway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM  \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='cycleway')
OR (
EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'cycle' AND tags.value='designated')
)" > "cycleway.sql"

echo "SELECT
  5153 AS layer_code, 'road' AS layer_class, 'footway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='footway')
OR (
EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'foot' AND tags.value='designated')
)" > "footway.sql"

echo "SELECT
  5154 AS layer_code, 'road' AS layer_class, 'footway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'cycle' AND tags.value='designated')
AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'foot' AND tags.value='designated')
AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'horse' AND tags.value='designated')" > "path.sql"

