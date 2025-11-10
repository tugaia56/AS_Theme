#!/bin/bash

TAG=${GITHUB_REF_NAME/v/}
NEWVERNAME=${TAG//v}
NEWVERCODE=${NEWVERNAME//.}

sed -i 's/versionCode.*/versionCode = '$NEWVERCODE'/' app/build.gradle.kts
sed -i 's/versionName =.*/versionName = "'$NEWVERNAME'"/' app/build.gradle.kts
sed -i 's/Dark_Shadow_Theme_.*/Dark_Shadow_Theme_'$TAG'")' app/build.gradle.kts