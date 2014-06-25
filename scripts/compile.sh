#!/bin/bash
# compile coffee
cd ../app/js
coffee -m -b -c *.coffee
cd services
coffee -m -b -c *.coffee
# uglify JS
cd ../../lib
uglifyjs jquery/dist/jquery.min.js angular/angular.min.js angular-route/angular-route.min.js angular-resource/angular-resource.min.js angular-animate/angular-animate.min.js angular-dynamic-locale/src/tmhDynamicLocale.js angular-translate/angular-translate.min.js angular-translate-loader-static-files/angular-translate-loader-static-files.min.js cryptojslib/rollups/hmac-sha1.js cryptojslib/components/enc-base64-min.js -o ../js/lib.min.js
cd ../js
uglifyjs app/*.js services/*.js -o app.min.js -c -m
# compile css
cd css
sass --scss -C -f -t compressed styles.scss styles.css
