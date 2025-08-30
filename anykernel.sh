### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Paradise Kernel by Cycle1337
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    4.1*) ksu_supported=true ;;
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

ui_print "Paradise Kernel by Cycle1337"
ui_print "Telegram: t.me/Cycle1337"
ui_print "Features: KPM, Fengchi Kernel(if available), O2, lz4kd/lz4 zram"
ui_print " "
ui_print "Flashing..."

if [ -L "/dev/block/bootdevice/by-name/init_boot_a" ] || [ -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot
    flash_boot
else
    dump_boot
    write_boot
fi

ZRAM_MODULE_PATH=$(find "$AKHOME" -type f -name "ZRAM-Module-*.zip" | head -n 1)

if [ -f "$ZRAM_MODULE_PATH" ]; then
    ui_print "  -> ZRAM Module found at $ZRAM_MODULE_PATH"
else
    ui_print "  -> No ZRAM Module found, skipping installation"
    ZRAM_MODULE_PATH=""
fi

if [ -n "$ZRAM_MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print "安装 ZRAM 模块?"
    ui_print "音量上跳过安装；音量下安装模块"
    ui_print "Install ZRAM Module?"
    ui_print "Volume UP: NO；Volume DOWN: YES"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done
    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print "Installing ZRAM Module..."
                /data/adb/ksud module install "$ZRAM_MODULE_PATH"
                ui_print "Installation Complete"
            else
                ui_print "KSUD Not Found, Skipping Installation"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print "Skipping ZRAM Module Installation"
            ;;
        *)
            ui_print "Unknown Key Input, Skipping Installation"
            ;;
    esac
fi

sleep 3
am start -a android.intent.action.VIEW -d tg://resolve?domain=Cycle1337 >/dev/null 2>&1 || true
