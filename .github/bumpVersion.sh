#!/bin/bash

NEWVERNAME=${GITHUB_REF_NAME/v/}
NEWVERCODE=${NEWVERNAME//.}

sed -i 's/versionCode.*/versionCode = '$NEWVERCODE'/' app/build.gradle.kts
sed -i 's/versionName =.*/versionName = "'$NEWVERNAME'"' app/build.gradle.kts
sed -i 's/Dark_Shadow_Theme_v.*/Dark_Shadow_Theme_v'$NEWVERNAME'")' app/build.gradle.kts