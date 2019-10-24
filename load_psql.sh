#!/bin/bash

export PGHOST="localhost"
export PGUSER="dheerajchand"
export PGPASSWORD=""
export PGPORT="5432"
export PGDATABASE="scratch"

schema="public"

tabblock_projection=4269

SRC_DIR="./downloads"
TARGET_DIR="./unzipped"

# for shapefile in $(find unzipped/ -type f -name '*.shp');
# do
#   tablename="$(basename "$shapefile" .shp)"
#   shp2pgsql -d -I -s $tabblock_projection $shapefile $schema.$tablename| psql
#
# done

# This directory has a lot of zipfiles that have to be unzipped and inserted into psql

for sub in $SRC_DIR/*/*;
do
  # create an unzip path for the shapefile
  flam=echo $sub | gcut --complement -d '/' -f 2
  flam2=echo $flam | gcut -c 1-
  echo $flam2
done
