#!/usr/bin/env python3
import argparse
import configparser
import os
import subprocess
import sys
from pathlib import Path
import operator
from datetime import datetime
import colorsys
import time

# ANSI escape codes for text formatting
BOLD = '\033[1m'
END = '\033[0m'
GREEN = '\033[32m'
RED = '\033[31m'
BLUE = '\033[34m'
YELLOW = '\033[33m'
PURPLE = '\033[35m'
CYAN = '\033[36m'
WHITE = '\033[37m'
BLACK = '\033[30m'

# Predefined list of 10 color pairs for gradients
THEME_COLORS = [
    ['#D32F2F', '#F57C00'], # Red -> Orange
    ['#1976D2', '#0097A7'], # Blue -> Cyan
    ['#388E3C', '#689F38'], # Green -> LightGreen
    ['#7B1FA2', '#512DA8'], # Purple -> DeepPurple
    ['#303F9F', '#1976D2'], # Indigo -> Blue
    ['#00796B', '#388E3C'], # Teal -> Green
    ['#C2185B', '#D32F2F'], # Pink -> Red
    ['#F57C00', '#E64A19'], # Orange -> DeepOrange
    ['#455A64', '#616161'], # BlueGrey -> Grey
    ['#5D4037', '#455A64'], # Brown -> BlueGrey
]

USER_JS_CONTENT = """
# auto install extensions
user_pref("extensions.autoDisableScopes", 0);
user_pref("extensions.enabledScopes", 15);
user_pref("extensions.installFromFile", true);

# new browser stuff
user_pref("app.normandy.first_run", false);
user_pref("app.normandy.migrationsApplied", 12);
user_pref("app.normandy.user_id", "01234567890-1234-1234-5678-123456789012");

user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);

user_pref("browser.bookmarks.addedImportButton", true);
user_pref("browser.bookmarks.restore_default_bookmarks", false);

user_pref("browser.tabs.groups.smart.enabled", false);


# Disable new tab sponsored content
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

# Disable Firefox accounts / sync
user_pref("identity.fxaccounts.enabled", false);

# AI crap
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.ml.chat.page", false);
user_pref("browser.ml.chat.shortcuts", false);
user_pref("browser.ml.enable", false);
user_pref("browser.ml.linkPreview.enabled", false);

# Disable telemetry and data collection
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("breakpad.reportURL", "");

# Set custom homepage
user_pref("browser.startup.homepage", "");
user_pref("browser.startup.page", 3); # 3 = restore previous session

# Disable autoplay
user_pref("media.autoplay.default", 5); # 5 = block all

# Disable DRM
user_pref("media.eme.enabled", false);

# Enable userChrome.css / userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

# Disable tab animations
user_pref("browser.tabs.animate", false);

# Prevent Firefox from checking if it's the default browser
user_pref("browser.shell.checkDefaultBrowser", false);

# Disable Pocket
user_pref("extensions.pocket.enabled", false);

# Disable Firefox View
user_pref("browser.tabs.firefox-view", false);
"""

UBLOCK_URL = "https://addons.mozilla.org/firefox/downloads/file/4531307/ublock.xpi"
UBLOCK_ID = "uBlock0@raymondhill.net"

def get_color_tuple_from_string(name):
    """Generates a pastel RGB color tuple from a string."""
    hash_val = 0
    for char in name:
        hash_val = ord(char) + ((hash_val << 5) - hash_val)

    hue = (hash_val % 360) / 360.0
    saturation = 0.6
    lightness = 0.85

    rgb_float = colorsys.hls_to_rgb(hue, lightness, saturation)
    return tuple(int(c * 255) for c in rgb_float)

def get_firefox_base_dir():
    snap_path = Path.home() / "snap/firefox/common/.mozilla/firefox"
    legacy_path = Path.home() / ".mozilla/firefox"
    if snap_path.is_dir():
        return snap_path
    return legacy_path

def get_profiles(base_dir):
    profiles_ini_path = base_dir / "profiles.ini"
    profiles = []

    if not profiles_ini_path.exists():
        return []

    config = configparser.ConfigParser()
    try:
        config.read(profiles_ini_path)
    except configparser.Error as e:
        print(f"Error reading profiles.ini: {e}", file=sys.stderr)
        return []

    for section in config.sections():
        if section.startswith("Profile"):
            try:
                name = config.get(section, "Name")
                path_str = config.get(section, "Path")
                is_relative = config.getint(section, "IsRelative", fallback=1)

                if is_relative:
                    path = base_dir / path_str
                else:
                    path = Path(path_str)

                if path.exists():
                    profiles.append({
                        "name": name,
                        "path": path,
                        "mtime": path.stat().st_mtime
                    })
            except (configparser.NoOptionError, configparser.NoSectionError):
                # This can happen if a profile is incompletely defined, skip it.
                continue
            except PermissionError:
                print(f"Warning: Permission denied for profile path '{path}'. Skipping.", file=sys.stderr)
                continue

    return profiles


def list_profiles(profiles):
    print("see also: $ firefox -ProfileManager")
    print("\nAvailable Firefox profiles:")
    if not profiles:
        print("  No profiles found.")
        return

    sorted_profiles = sorted(profiles, key=operator.itemgetter('mtime'), reverse=True)
    for profile in sorted_profiles:
        mtime_str = datetime.fromtimestamp(profile['mtime']).strftime('%Y-%m-%d %H:%M:%S')
        print(f"  - {BOLD}{GREEN}{profile['name']}{END} (Last modified: {mtime_str})")
        print(f"    Path: {profile['path']}")


def get_last_used_profile(profiles):
    if not profiles:
        return None

    # Simply return the most recently modified profile.
    sorted_profiles = sorted(profiles, key=operator.itemgetter('mtime'), reverse=True)
    return sorted_profiles[0]


def create_profile(profile_name, base_dir):
    print(f"Creating new profile: {profile_name}")
    subprocess.run(["firefox", "-no-remote", "-CreateProfile", f"{profile_name}"], check=True)

    # Poll for 5 seconds to wait for the profile to appear in profiles.ini
    print("Waiting for profile to be created...")
    new_profile = None
    for _ in range(50):  # 50 * 0.1s = 5 seconds
        profiles = get_profiles(base_dir)
        new_profile = next((p for p in profiles if p['name'] == profile_name), None)
        if new_profile:
            break
        time.sleep(0.1)

    if not new_profile:
        print(f"Error: Timed out waiting for profile '{profile_name}' to be created.", file=sys.stderr)
        sys.exit(1)

    print("Profile found.")
    profile_path = new_profile['path']

    # --- Create userChrome.css for theme ---
    # Select a color pair from the predefined list based on profile name hash
    hash_val = 0
    for char in profile_name:
        hash_val = ord(char) + ((hash_val << 5) - hash_val)

    color_index = hash_val % len(THEME_COLORS)
    main_color_opaque, second_color_opaque = THEME_COLORS[color_index]

    print(f"Selected theme {color_index} for '{profile_name}': {main_color_opaque} -> {second_color_opaque}")

    chrome_dir = profile_path / "chrome"
    chrome_dir.mkdir(exist_ok=True)

    user_chrome_content = f"""
/*
 * This file is auto-generated by ff_profile.py for the '{profile_name}' profile.
 * AGGRESSIVE THEME (No CSS Variables)
 */
@namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

/* --- AGGRESSIVE THEME START --- */

/* Apply gradient to all main toolbars and window controls */
#navigator-toolbox,
#TabsToolbar,
#PersonalToolbar,
.titlebar-buttonbox-container,
#bookmarks-toolbar-placeholder {{
    background-image: linear-gradient(to right, {main_color_opaque}, {second_color_opaque}) !important;
    background-color: {main_color_opaque} !important; /* Fallback */
    color: #FFFFFF !important;
    text-shadow: 1px 1px 2px #000000 !important;
}}

/* Ensure window control buttons are visible */
.titlebar-button > .toolbarbutton-icon {{
    fill: #FFFFFF !important;
}}
.titlebar-button:hover {{
    background-color: rgba(255,255,255,0.2) !important;
}}


/* Style for all tabs */
.tab-background {{
    background-image: linear-gradient(to right, {main_color_opaque}, {second_color_opaque}) !important;
    background-color: {main_color_opaque} !important; /* Fallback */
    opacity: 0.5;
}}
.tab-content {{
    color: #FFFFFF !important;
    text-shadow: 1px 1px 2px #000000 !important;
}}

/* Style for the selected tab - make it fully opaque */
.tab-background[selected="true"] {{
    opacity: 1.0 !important;
}}

/* Hovered tabs */
.tab-background:not([selected="true"]):hover {{
    opacity: 0.8 !important;
}}

/* URL bar styling */
#urlbar-background {{
    background-color: rgba(0, 0, 0, 0.2) !important;
    border-color: rgba(255, 255, 255, 0.3) !important;
}}
#urlbar-input-container {{
    color: #FFFFFF !important;
    text-shadow: 1px 1px 1px #000000 !important;
}}

/* --- AGGRESSIVE THEME END --- */
"""
    user_chrome_path = chrome_dir / "userChrome.css"
    user_chrome_path.write_text(user_chrome_content)
    print(f"Created userChrome.css theme in: {user_chrome_path}")

    # --- Write user.js and install uBlock Origin ---
    user_js_path = profile_path / "user.js"
    print(f"Writing user.js to {user_js_path}")
    user_js_path.write_text(USER_JS_CONTENT)

    extensions_dir = profile_path / "extensions"
    extensions_dir.mkdir(exist_ok=True)
    ublock_xpi_path = extensions_dir / f"{UBLOCK_ID}.xpi"
    print(f"Downloading and installing uBlock Origin to {ublock_xpi_path}")
    try:
        subprocess.run(["wget", UBLOCK_URL, "-O", str(ublock_xpi_path)], check=True, capture_output=True)
        print("uBlock Origin installed successfully.")
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"Error: Failed to download uBlock Origin. Please install it manually.", file=sys.stderr)
        if isinstance(e, subprocess.CalledProcessError):
            print(e.stderr.decode(), file=sys.stderr)


def launch_profile(profile_name, profiles):
    profile_to_launch = next((p for p in profiles if p['name'] == profile_name), None)
    if not profile_to_launch:
        return False

    print(f"Launching Firefox with profile: {profile_name}")
    subprocess.Popen(["firefox", "-P", profile_name, "-no-remote"])
    return True

def main():
    parser = argparse.ArgumentParser(description="Manage and launch Firefox profiles.")
    parser.add_argument("profile_name", nargs="?", default=None, help="Name of the profile to launch or create. If omitted, lists available profiles.")
    parser.add_argument("-l", "--list", action="store_true", help="List all available profiles.")

    args = parser.parse_args()

    base_dir = get_firefox_base_dir()
    profiles = get_profiles(base_dir)

    if args.list or not args.profile_name:
        list_profiles(profiles)
        sys.exit(0)

    if args.profile_name:
        profile_name = args.profile_name
        if not any(p['name'] == profile_name for p in profiles):
            create_profile(profile_name, base_dir)
            profiles = get_profiles(base_dir)

        if not launch_profile(profile_name, profiles):
            print(f"Error: Profile '{profile_name}' not found.", file=sys.stderr)
            sys.exit(1)

if __name__ == "__main__":
    main()
