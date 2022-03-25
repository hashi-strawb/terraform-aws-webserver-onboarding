#!/bin/bash

source ../env.sh

HCP_PACKER_BUILD_FINGERPRINT=v0.1.0-$(date +%F_%H-%M-%S) packer build .
