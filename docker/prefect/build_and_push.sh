#!/bin/bash

docker build . -t smandaric/prefect:winequality-v1
docker push smandaric/prefect:winequality-v1