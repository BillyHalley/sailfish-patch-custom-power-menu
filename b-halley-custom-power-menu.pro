# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = b-halley-custom-power-menu

TEMPLATE = aux

patch.path = /usr/share/patchmanager/patches/b-halley-custom-power-menu
patch.files = data/unified_diff.patch data/patch.json

setting.path = /usr/share/jolla-settings/pages/b-halley-custom-power-menu
setting.files = settings/*.qml settings/*.png

entry.path = /usr/share/jolla-settings/entries
entry.files = settings/b-halley-custom-power-menu.json

icon.path = /usr/share/patchmanager/patches/b-halley-custom-power-menu/icons
icon.files = icons/*.png

INSTALLS += \
        patch \
        setting \
        entry \
        icon

OTHER_FILES += \
    rpm/b-halley-custom-power-menu.spec \
    rpm/b-halley-custom-power-menu.yaml \
    data/patch.json \
    settings/b-halley-custom-power-menu.json \
    settings/main.qml \
    rpm/b-halley-custom-power-menu.changes \
    settings/SettingsPowerButton.qml \
    settings/PowerPage.qml \
    settings/LockPage.qml \
    qml/a/usr/share/lipstick-jolla-home-qt5/powerkey/PowerButton.qml \
    qml/a/usr/share/lipstick-jolla-home-qt5/powerkey/PowerKeyMenu.qml \
    qml/b/usr/share/lipstick-jolla-home-qt5/powerkey/PowerButton.qml \
    qml/b/usr/share/lipstick-jolla-home-qt5/powerkey/PowerKeyMenu.qml \
    data/unified_diff.patch
