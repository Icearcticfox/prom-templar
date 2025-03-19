#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IMAGE="templatizator:amd64:1.0.0"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    IMAGE="templatizator:arm64:1.0.0"
else
    echo "Unsupported platform"
    exit 1
fi

common_templates=$(git status --short | grep -E "common_templates" | wc -l); \
if [ $common_templates -gt 0 ]; then \
  dirs="teams/*/*"; \
else \
  dirs=$(git status --short | \
  grep -E "common_templates|teams" | \
  cut -c4- | \
  while read -r file; do \
    dir=$(dirname $file); \
    while [ "$(echo $dir | grep -o '/' | wc -l)" -gt "2" ]; do \
      dir=$(dirname $dir); \
    done; \
    echo $dir; \
  done | sort -u); \
fi; \

echo $dirs

docker run --rm -v "$(pwd):/app" --env dirs=$dirs $IMAGE make all
