#!/bin/bash

# Copyright (c) 2011, Intel Corporation.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Regression script will vary LBA formats from 0 to n which are defined by
# the format.*.xml files. These files use combinations of LBA data sizes:
# {512, 1024, 2048 and 4096} and meta data sizes: {0, 8, 64, 128}.
# The script needs the format.*.xml files. When you run
# ./regression.sh <user param> it invokes ./runtnvme -f <format.*.xml>
# to format namespace. For each iteration namespace #1 is formatted
# with the LBA and MS settings from the corresponding xml file.
# Once the namespace is formatted, the regression script invokes
# ./runtnvme <user param> to run entire compliance suite or part of it as
# specified in the parmaters.
# If any failure is detected either when formatting the namespace or when
# a test throws an expection, the script immediately stops for user to
# investigate.

TNVME_CMD_LINE=$@
FILES=format.*.xml

Usage() {
echo "usage...."
echo "  $0 <tnvme cmd line options>"
echo ""
}

if [ -z "$TNVME_CMD_LINE" ]; then
  Usage
  exit -1
fi

file=0
# Loop through all the format files available in the current directory. 
for f in $FILES
do
echo "FormatNVM using $f for nsid = 1"
./runtnvme.sh -f $f
ret=${PIPESTATUS[0]}
if [[ $ret -ne 0 ]]; then
    echo "Failed formatting using $f"
    exit $ret
fi

# Calling runtnvme script using the same command line options which the user
# supplied when executing the regression script.
./runtnvme.sh $TNVME_CMD_LINE
ret=${PIPESTATUS[0]}
if [[ $ret -ne 0 ]]; then
    echo "Failed when executing test suite using $f formatted namespace."
    exit $ret
fi
file=$(($file+1))
done
echo "Total LBA formatted xml files $file."
exit $ret
