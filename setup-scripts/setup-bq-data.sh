#!/usr/bin/env bash
DATASET_NAME=greenhat
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

bq ls $DATASET_NAME || bq mk --dataset --location europe-north1 $DATASET_NAME

gcs_readings=gs://green-hat-h4ck325/dump.rx4-partial.csv
url_road_config=https://node25.rx4.hello-world.sh/road_config.csv
gcs_space_and_time=gs://green-hat-h4ck325/space_and_time_continuum.csv

if [ ! -f $SCRIPT_DIR/dump.rx4-partial.csv ]
then
    gsutil cp $gcs_readings $SCRIPT_DIR
fi
if [ ! -f $SCRIPT_DIR/space_and_time_continuum.csv ]
then
    gsutil cp $gcs_space_and_time $SCRIPT_DIR
fi
if [ ! -f $SCRIPT_DIR/road_config.csv ]
then
    wget -P $SCRIPT_DIR $url_road_config
fi

bq show $DATASET_NAME.readings > /dev/null || bq --location=europe-north1 load --autodetect  --source_format=CSV $DATASET_NAME.readings $SCRIPT_DIR/dump.rx4-partial.csv
bq show $DATASET_NAME.space_and_time_continuum > /dev/null || bq --location=europe-north1 load --autodetect  --source_format=CSV $DATASET_NAME.space_and_time_continuum $SCRIPT_DIR/space_and_time_continuum.csv
bq show $DATASET_NAME.road_config > /dev/null || bq --location=europe-north1 load --autodetect  --source_format=CSV $DATASET_NAME.road_config $SCRIPT_DIR/road_config.csv