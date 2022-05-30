#!/bin/bash

docker build . -t smandaric/winequality-scipy-notebook:v2
docker push smandaric/winequality-scipy-notebook:v2