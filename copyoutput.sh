rm -rf ./output/
mkdir output

target_home_dir=$(pwd)
docker cp ff53b9e81bf2:$target_home_dir/output/ ./output/

