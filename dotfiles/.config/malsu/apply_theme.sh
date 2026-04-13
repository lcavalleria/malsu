#!/bin/bash
echo -n "Apply theme colors: "
echo -n "Hyprland"
gomplate \
  -d theme=file:///$HOME/.config/malsu/theme.yaml \
  -f $HOME/.config/hypr/theme.conf.tmpl \
  -o $HOME/.config/hypr/theme.conf

echo -n ", Kitty"
gomplate \
  -d theme=file:///$HOME/.config/malsu/theme.yaml \
  -f $HOME/.config/kitty/theme.conf.tmpl \
  -o $HOME/.config/kitty/theme.conf

echo -n ", waybar"
gomplate \
  -d theme=file:///$HOME/.config/malsu/theme.yaml \
  -f $HOME/.config/waybar/theme.css.tmpl \
  -o $HOME/.config/waybar/theme.css

echo ", wofi"
gomplate \
  -d theme=file:///$HOME/.config/malsu/theme.yaml \
  -f $HOME/.config/wofi/theme.css.tmpl \
  -o $HOME/.config/wofi/theme.css
