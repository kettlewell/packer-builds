#!/bin/sh -eux

# https://bugzilla.redhat.com/show_bug.cgi?id=1212883

myrel="$(awk '{print $4}' /etc/centos-release | cut -d. -f1,2)"
if [ "${myrel}" != '7.1' ]; then
	exit 0
fi

pdir=$(mktemp -d "${TMPDIR:-/tmp}/${0##*/}.XXXXXX")
cat > "${pdir}/patch" <<'EOF'
--- network-functions	2015-01-15 08:57:03.000000000 +0000
+++ network-functions	2015-10-08 22:03:51.911780956 +0000
@@ -532,10 +532,10 @@
 change_resolv_conf ()
 {
     s=$(/bin/grep '^[\ \	]*option' /etc/resolv.conf 2>/dev/null);
-    if [ "x$s" != "x" ]; then
-       s="$s"$'\n';
-    fi;
     if [ $# -gt 1 ]; then
+       if [ "x$s" != "x" ]; then
+          s="$s"$'\n';
+       fi;
        n_args=$#;
        while [ $n_args -gt 0 ]; 
 	 do 
@@ -553,7 +553,7 @@
          done;       
     elif [ $# -eq 1 ]; then
        if [ "x$s" != "x" ]; then
-	  s="$s"$(/bin/grep -vF "$s" $1);
+	  s="$s"$'\n'$(/bin/grep -vF "$s" $1);
        else
 	  s=$(cat $1);
        fi;
EOF

cd /etc/sysconfig/network-scripts
patch -p0 < "${pdir}/patch"

rm -fr "${pdir}"
