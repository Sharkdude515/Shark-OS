#!/bin/bash
set -euo pipefail

# ==========================================
# SHARK-OS VISUAL LAYOUT CONFIGURATION
# ==========================================
GTK_THEME="Arc-Dark"
WINDOW_BORDER="Arc-Dark"
ICON_THEME="Papirus-Dark"
WALLPAPER_PATH="/usr/share/backgrounds/sharkos/background2.png"
WHISKER_ICON="/usr/share/logo.png"

PANEL_POSITION="top"
PANEL_SIZE=34
PANEL_DARK_MODE=true

ENABLE_PLANK_DOCK=false
# ==========================================

SKEL_CONF="/etc/skel/.config"
mkdir -p "$SKEL_CONF/xfce4/xfconf/xfce-perchannel-xml" "$SKEL_CONF/xfce4/panel" "$SKEL_CONF/autostart"

# 1. Apply GTK Theme & Icon Theme
cat << EOF > "$SKEL_CONF/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="${GTK_THEME}"/>
    <property name="IconThemeName" type="string" value="${ICON_THEME}"/>
  </property>
</channel>
EOF

# 2. Apply Window Border Theme & Enable Compositing (Required for Plank transparency)
cat << EOF > "$SKEL_CONF/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="${WINDOW_BORDER}"/>
    <property name="use_compositing" type="bool" value="true"/>
  </property>
</channel>
EOF

# 3. Apply Desktop Wallpaper (Covers common monitor outputs: screen0/monitor0, Virtual-1, HDMI-1, eDP-1)
cat << EOF > "$SKEL_CONF/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="${WALLPAPER_PATH}"/>
        </property>
      </property>
      <property name="monitorVirtual-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="${WALLPAPER_PATH}"/>
        </property>
      </property>
      <property name="monitoreDP-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="${WALLPAPER_PATH}"/>
        </property>
      </property>
      <property name="monitorHDMI-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="${WALLPAPER_PATH}"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

# 4. Configure Main Panel Position, Size, Dark Mode & Applets
case "$PANEL_POSITION" in
  top)    P_MODE=0; P_POS="p=6;x=0;y=0" ;;
  left)   P_MODE=1; P_POS="p=2;x=0;y=0" ;;
  right)  P_MODE=1; P_POS="p=4;x=0;y=0" ;;
  bottom|*) P_MODE=0; P_POS="p=8;x=0;y=0" ;;
esac

cat << EOF > "$SKEL_CONF/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="${PANEL_DARK_MODE}"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="${P_POS}"/>
      <property name="size" type="uint" value="${PANEL_SIZE}"/>
      <property name="mode" type="uint" value="${P_MODE}"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
EOF

# 5. Configure Whisker Menu Custom Icon (Matches plugin-1 ID from xfce4-panel.xml)
cat << EOF > "$SKEL_CONF/xfce4/panel/whiskermenu-1.rc"
button-icon=${WHISKER_ICON}
button-single-row=false
show-button-title=false
show-button-icon=true
EOF

# 6. Configure Plank Mac-Style Dock
if [ "$ENABLE_PLANK_DOCK" = "true" ]; then
  cat << 'EOF' > "$SKEL_CONF/autostart/plank.desktop"
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
fi

# 7. Configure LightDM GTK Greeter (Login Screen)
mkdir -p /etc/lightdm/lightdm-gtk-greeter.conf.d
cat << EOF > /etc/lightdm/lightdm-gtk-greeter.conf.d/99-sharkos.conf
[greeter]
background=${WALLPAPER_PATH}
default-user-image=${WHISKER_ICON}
theme-name=${GTK_THEME}
icon-theme-name=${ICON_THEME}
hide-user-image=false
EOF

# 8. Apply to all existing user home folders safely
for USER_HOME in /home/*; do
  if [ -d "$USER_HOME" ] && [ "$(basename "$USER_HOME")" != "lost+found" ]; then
    USERNAME=$(basename "$USER_HOME")
    if id "$USERNAME" &>/dev/null; then
      mkdir -p "$USER_HOME/.config"
      cp -rT "$SKEL_CONF" "$USER_HOME/.config"
      chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config"
    fi
  fi
done

# 9. Safely refresh LightDM only if the graphical session is already running
if systemctl is-active --quiet lightdm; then
  systemctl restart lightdm || true
fi
