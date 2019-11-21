#!/bin/sh

NONOP_TYPES=("53:proposed" "54:construction" "55:disused" "56:abandoned")
LAYER=(
        "11:highway=motorway"
        "12:highway=trunk"
        "13:highway=primary"
        "14:highway=secondary"
        "15:highway=tertiary"
        "21:highway=unclassified"
        "22:highway=residental"
        "23:highway=living_street"
        "24:highway=pedestrian"
        "31:highway=motorway_link"
        "32:highway=trunk_link"
        "33:highway=primary_link"
        "34:highway=secondary_link"
        "41:highway=service"
        "42:highway=track"
        "55:highway=steps"
        "60:route=ferry"
        "99:highway=road"

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
    echo "SELECT
$CODE AS layer_code, 'nonop' AS layer_class, '${V}_${NONOP_TYPE}' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = '$K' AND tags.value='proposed')
AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'proposed' AND tags.value='$V')
" > "${V}_${NONOP_TYPE}.sql"
  done
done
#
#LAYER=(
#        "5143:track_grade1:tracktype=grade1"
#        "5144:track_grade2:tracktype=grade2"
#        "5145:track_grade3:tracktype=grade3"
#        "5146:track_grade4:tracktype=grade4"
#        "5147:track_grade5:tracktype=grade5"
#)
#
#
#for layer in "${LAYER[@]}"
#do
#  CODE="${layer%%:*}"
#  KV="${layer##*:}"
#  T="${layer#*:}"
#  C="${T%%:*}"
#  KV="${T##*:}"
#  K="${KV%%=*}"
#  V="${KV##*=}"
#
#  echo "SELECT
#  $CODE AS layer_code, 'road' AS layer_class, '$C' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
#FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
#WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='track')
#AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = '$K' AND tags.value='$V')" > "$C.sql"
#done
#
#echo "SELECT
#  5151 AS layer_code, 'road' AS layer_class, 'bridleway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
#FROM  \`${GCP_PROJECT}.${BQ_DATASET}.features\`
#WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='bridleway')
#OR (
#EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
#AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'horse' AND tags.value='designated')
#)" > "bridleway.sql"
#
#echo "SELECT
#  5152 AS layer_code, 'road' AS layer_class, 'cycleway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
#FROM  \`${GCP_PROJECT}.${BQ_DATASET}.features\`
#WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='cycleway')
#OR (
#EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
#AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'cycle' AND tags.value='designated')
#)" > "cycleway.sql"
#
#echo "SELECT
#  5153 AS layer_code, 'road' AS layer_class, 'footway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
#FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
#WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) AS tags WHERE tags.key = 'highway' AND tags.value='footway')
#OR (
#EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
#AND EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'foot' AND tags.value='designated')
#)" > "footway.sql"
#
#echo "SELECT
#  5154 AS layer_code, 'road' AS layer_class, 'footway' AS layer_name, feature_type AS gdal_type, osm_id, osm_way_id, osm_timestamp, all_tags, geometry
#FROM \`${GCP_PROJECT}.${BQ_DATASET}.features\`
#WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'highway' AND tags.value='path')
#AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'cycle' AND tags.value='designated')
#AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'foot' AND tags.value='designated')
#AND NOT EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'horse' AND tags.value='designated')" > "path.sql"
#
