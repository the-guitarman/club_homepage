#!/usr/bin/env bash

#docker container run -v $(pwd):/opt/build --rm -it elixir-ubuntu:18_04 /opt/build/build_release_within_docker.sh
docker container run -v $(pwd):/opt/build --rm elixir-ubuntu:18_04 /opt/build/build_release_within_docker.sh
