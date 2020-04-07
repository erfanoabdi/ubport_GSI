# Ubport GSI installer Script
# erfanoabdi @ xda-developers
OUTFD=/proc/self/fd/$1;

# ui_print <text>
ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }

## GSI install

cp -fpr /data/ubports/data/* /data/;

mkdir /s;
mkdir /r;
mount /data/system.img /s;
mount /data/rootfs.img /r;

ui_print "Setting udev rules";
cat /s/ueventd*.rc /vendor/ueventd*.rc | grep ^/dev | sed -e 's/^\/dev\///' | awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' > /r/etc/udev/rules.d/70-ubport.rules;

ui_print "Setting phone DPI";
echo "GRID_UNIT_PX=24" >> /r/etc/ubuntu-touch-session.d/android.conf;
echo "QTWEBKIT_DPR=2.0" >> /r/etc/ubuntu-touch-session.d/android.conf;
echo "FORM_FACTOR=handset" >> /r/etc/ubuntu-touch-session.d/android.conf;

umount /r;
umount /s;

## end install
