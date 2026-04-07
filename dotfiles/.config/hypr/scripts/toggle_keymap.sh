#!/bin/bash

CURRENT=$(hyprctl devices -j | jq -r '.keyboards[0].layout' | tr 'a-z' 'A-Z')

if [[ "$CURRENT" == "US" ]]; then
  hyprctl keyword input:kb_layout es
  hyprctl keyword input:kb_model pc105
else
  hyprctl keyword input:kb_layout us
  hyprctl keyword input:kb_model pc104
fi
