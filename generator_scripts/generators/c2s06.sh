#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step excludes the files in spec/support from packwerk analysis
#
###############################################################################

sed -i "/exclude:/a\- 'spec\/support\/**\/*'" packwerk.yml
