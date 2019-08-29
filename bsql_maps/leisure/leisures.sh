#!/bin/sh

for LAYER in park playground dog_park sports_centre pitch swimming_pool water_park golf_course \
    stadium ice_rink
do
    echo "SELECT
  *
FROM \`openstreetmap-public-data-dev.osm_planet.points\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'leisure' AND tags.value='${LAYER}')
UNION ALL
SELECT
  *
FROM \`openstreetmap-public-data-dev.osm_planet.multipolygons\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'leisure' AND tags.value='${LAYER}')
UNION ALL
SELECT
  *
FROM \`openstreetmap-public-data-dev.osm_planet.other_relations\`
WHERE EXISTS(SELECT 1 FROM UNNEST(all_tags) as tags WHERE tags.key = 'leisure' AND tags.value='${LAYER}')
" > "leisures-${LAYER}.sql"
done
