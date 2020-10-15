# Ubport GSI installer Script
# erfanoabdi @ xda-developers
OUTFD=/proc/self/fd/$1;

# ui_print <text>
ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }

## GSI install

cp -fpr /data/ubports/data/* /data/;

touch /data/.writable_device_image;
touch /data/.writable_image;

mkdir /s;
mkdir /r;

mount /data/system.img /s;
ui_print "Setting udev rules";
cat /s/ueventd*.rc /vendor/ueventd*.rc | grep ^/dev | sed -e 's/^\/dev\///' | awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' > /data/70-ubport.rules;
umount /s;

mount /data/rootfs.img /r;
mv /data/70-ubport.rules /r/etc/udev/rules.d/70-ubport.rules;
echo "FORM_FACTOR=handset" >> /r/etc/ubuntu-touch-session.d/android.conf;
if grep -q ro.sf.lcd_density /vendor/build.prop; then
    PX=`grep ro.sf.lcd_density /vendor/build.prop | cut -d "=" -f 2 | awk '{$1=int($1/20);printf $1}'`;
    DPR=`grep ro.sf.lcd_density /vendor/build.prop | cut -d "=" -f 2 | awk '{$1=int($1/20);$1=$1/10.0;printf $1}'`;
    ui_print "Setting phone DPI";
    echo "GRID_UNIT_PX=$PX" >> /r/etc/ubuntu-touch-session.d/android.conf;
    echo "QTWEBKIT_DPR=$DPR" >> /r/etc/ubuntu-touch-session.d/android.conf;
fi
umount /r;

mv /data/system.img /data/android-rootfs.img

ui_print "Resizing rootfs to 8GB";
e2fsck -fy /data/rootfs.img
resize2fs /data/rootfs.img 8G

## end install
