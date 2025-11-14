#!/bin/bash

NEWVERNAME=${GITHUB_REF_NAME/v/}

# sub changelog
EN_CHANGELOG="./app/src/main/res/values/changelog.xml"
IT_CHANGELOG="./app/src/main/res/values-it/changelog.xml"

#temp changelog
TMP_CHANGELOG="tmp_changelog_lines.md"
TMP_ADDED="tmp_added.md"
TMP_UPDATED="tmp_updated.md"
TMP_REMOVED="tmp_removed.md"
rm -f tmp_*

# reset the file - most likely not needed
rm -f changeLog.md
rm -f Tchangelog.htm
touch changeLog.md
touch $TMP_CHANGELOG
touch Tchangelog.htm

#find the last time we made a changelog
LASTUPDATE=$(git log -1000 | grep -B 4 "Version update: Release" | grep "commit" -m 1 | cut -d " " -f 2)
#find commits since - starting with the magic phrase
ADDED=$(git rev-list $LASTUPDATE..HEAD --grep "^ADDED: ")
UPDATED=$(git rev-list $LASTUPDATE..HEAD --grep "^UPDATED: ")
REMOVED=$(git rev-list $LASTUPDATE..HEAD --grep "^REMOVED: ")
#vars
declare -i NUMADDED=0
declare -i NUMUPDATED=0
declare -i NUMREMOVED=0
#separator is newline
IFS=$'\n'
for COMMIT in $ADDED
do
  COMMITMSGS=$(git show $COMMIT --pretty=format:"%s" | grep "^ADDED: " | tr -d '\0')
    for LINE in $COMMITMSGS
    do
      #save in the temp file to be used by next script
      echo "- "${LINE##*ADDED: }"  " >> $TMP_ADDED
	    ((NUMADDED++))
    done
done
for COMMIT in $UPDATED
do
  COMMITMSGS=$(git show $COMMIT --pretty=format:"%s" | grep "^UPDATED: " | tr -d '\0')
    for LINE in $COMMITMSGS
    do
      #save in the temp file to be used by next script
      echo "- "${LINE##*UPDATED: }"  " >> $TMP_UPDATED
      ((NUMUPDATED++))
    done
done
for COMMIT in $REMOVED
do
  COMMITMSGS=$(git show $COMMIT --pretty=format:"%s" | grep "^REMOVED: " | tr -d '\0')
    for LINE in $COMMITMSGS
    do
      #save in the temp file to be used by next script
      echo "- "${LINE##*REMOVED: }"  " >> $TMP_REMOVED
      ((NUMREMOVED++))
    done
done


rm -f $EN_CHANGELOG
rm -f $IT_CHANGELOG

touch $EN_CHANGELOG

# start changelog
echo '<?xml version="1.0" encoding="utf-8"?>' >> $EN_CHANGELOG
echo "<resources>" >> $EN_CHANGELOG
echo '    <string-array name="ThemeChangelog">' >> $EN_CHANGELOG
echo '        <item>Version '$NEWVERNAME'</item>' >> $EN_CHANGELOG

if [ $NUMADDED -gt 0 ]; then
  echo "## Added  " >> $TMP_CHANGELOG
  cat $TMP_ADDED >> $TMP_CHANGELOG
  echo "        <item>ADDED:</item>" >> $EN_CHANGELOG
  for i in $(cat < "$TMP_ADDED"); do
    echo "        <item>${i/- /}</item>" >> $EN_CHANGELOG
  done
fi
if [ $NUMUPDATED -gt 0 ]; then
  echo "## Updated  " >> $TMP_CHANGELOG
  cat $TMP_UPDATED >> $TMP_CHANGELOG
  echo "        <item>UPDATED:</item>" >> $EN_CHANGELOG
    for i in $(cat < "$TMP_UPDATED"); do
      echo "        <item>${i/- /}</item>" >> $EN_CHANGELOG
    done
fi
if [ $NUMREMOVED -gt 0 ]; then
  echo "## Removed  " >> $TMP_CHANGELOG
  cat $TMP_REMOVED >> $TMP_CHANGELOG
  echo "        <item>REMOVED:</item>" >> $EN_CHANGELOG
      for i in $(cat < "$TMP_REMOVED"); do
        echo "        <item>${i/- /}</item>" >> $EN_CHANGELOG
      done
fi
awk '!seen[$0]++' "$TMP_CHANGELOG" >> changeLog.md

# end changelog
echo "    </string-array>" >> $EN_CHANGELOG
echo "</resources>" >> $EN_CHANGELOG
cp $EN_CHANGELOG $IT_CHANGELOG
sed -i 's/ADDED/AGGIUNTO/g' $IT_CHANGELOG
sed -i 's/UPDATED/MODIFICATO/g' $IT_CHANGELOG
sed -i 's/REMOVED/RIMOSSO/g' $IT_CHANGELOG

echo "*Dark Shadow Theme v$NEWVERNAME released!*" > body.msg
echo "  " >> body.msg
echo "*Changelog:*  " >> body.msg
cat changeLog.md >> body.msg
echo 'Body<<EOF' >> $GITHUB_ENV
cat body.msg >> $GITHUB_ENV
echo 'EOF' >> $GITHUB_ENV

echo "[🌎 Site Dark Shadows Theme](https://mythemedarkandmore.altervista.org/)" > telegram.msg
echo " " >> telegram.msg
echo "⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️" >> telegram.msg
echo " " >> telegram.msg
cat changeLog.md >> telegram.msg
echo " " >> telegram.msg
echo "If you find any bugs or incorrect colors, please report them to the group and I'll fix them as soon as possible. Thank you very much." >> telegram.msg
echo "For those of you using OxygenOS, I recommend using Oxygen Customizer; it has many extra features." >> telegram.msg
echo " " >> telegram.msg
echo "[🙇 Support the developer ❤️](https://www.paypal.com/donate/?business=UGACHZ2UGBEBJ&no_recurring=1&currency_code=EUR)" >> telegram.msg
echo " " >> telegram.msg
echo "Thank you all" >> telegram.msg
echo 'TMessage<<EOF' >> $GITHUB_ENV
cat telegram.msg >> $GITHUB_ENV
echo 'EOF' >> $GITHUB_ENV