#!/sbin/sh

propfile="/system/etc/backup.conf"
vendorpropfile="/system/vendor/build.prop"
backupfile="/tmp/backup/backup.conf"
backuppath="/tmp/backup"
mkdir -p $backuppath
propbackuppath="$backuppath/prop"
vendorpropbackuppath="$backuppath/vendor"
mkdir -p $propbackuppath
mkdir -p $vendorpropbackuppath

persist_lcd_density=1

load_prop() {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

backup_prop() {
    cp "/system/build.prop" "$propbackuppath/build.prop"
}

backup_vendor_prop() {
    cp "$vendorpropfile" "$vendorpropbackuppath/build.prop"
}

restore_prop() {
    if [ "$persist_lcd_density" = "1" ]; then
            if [ -f "$propbackuppath/build.prop" ]; then
                local USERLCD=`sed -n -e'/ro\.sf\.lcd_density/s/^.*=//p' $propbackuppath/build.prop`
                busybox sed -i "s|ro.sf.lcd_density=.*|ro.sf.lcd_density=$USERLCD|" /system/build.prop
            fi
    fi
}

restore_vendor_prop() {
    if [ "$persist_lcd_density" = "1" ]; then
            if [ -f "$vendorpropbackuppath/build.prop" ]; then
                cp "$vendorpropbackuppath/build.prop" "$vendorpropfile"
            fi
    fi
}

backup_file() {
    if [ -f "$propfile" ]; then
        cp "$propfile" "$backupfile"
    fi
}

restore_file() {
    if [ -f "$backupfile" ]; then
        cp "$backupfile" "$propfile"
    fi
}

case "$1" in
    backup)
        backup_file
        load_prop "$backupfile"
        backup_prop
        backup_vendor_prop
        ;;
    restore)
        restore_file
        load_prop "$backupfile"
        restore_prop
        restore_vendor_prop
        ;;
    pre-backup)
        ;;
    post-backup)
        ;;
    pre-restore)
        ;;
    post-restore)
        ;;
esac
exit 0
