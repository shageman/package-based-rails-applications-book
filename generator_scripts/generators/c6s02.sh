#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves the predictor class into the public part of predictor package
#
###############################################################################


# mkdir -p ./packages/predictor/app/public/predictor

# mv ./packages/predictor/app/models/predictor/* ./packages/predictor/app/public/predictor


## This section is a not-op since we introduced public/predictor in c4s02