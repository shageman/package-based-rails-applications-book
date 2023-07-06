#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves the predictor class into the public part of predictor package
#
###############################################################################


# mkdir -p ./packs/predictor/app/public/predictor

# mv ./packs/predictor/app/models/predictor/* ./packs/predictor/app/public/predictor


## This section is a not-op since we introduced public/predictor in c4s02