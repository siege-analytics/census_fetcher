# https://stackoverflow.com/questions/5986942/how-to-copy-all-files-via-ftp-in-rsync


years=( "2019" )
geographies=("TABBLOCK" "COUNTY" "SLDL" "SLDU" "STATE" "ZCTA5")

LOCAL_PARENT_DIR='downloads'
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DOWNLOAD_DIR=$APP_DIR/$LOCAL_PARENT_DIR

for y in "${years[@]}"                 # outer loop is years
do
	for g in "${geographies[@]}"         # inner loop is geographies
  do
    echo "Working on : ${y} : ${g} \n"
    target_directory=$DOWNLOAD_DIR/${y}/${g}
    mkdir -p $target_directory        # make a receipt path for the data
    url="ftp://ftp2.census.gov//geo/tiger/TIGER${y}/${g}/"
    cd $target_directory
    wget \
      --continue \
      --mirror \
      --no-host-directories \
      $url
  done
done
