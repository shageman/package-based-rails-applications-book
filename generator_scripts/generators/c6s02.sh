#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves the predictor class into the public part of predictor package
#
###############################################################################

mkdir -p ./packages/predictor/app/public

mv ./packages/predictor/app/models/* ./packages/predictor/app/public


