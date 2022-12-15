#!/bin/bash
if [ -e "meteor.local.sh" ]; then
  ./meteor.local.sh $@
else
  meteor $@
fi
