#!/bin/bash
cd ../app/js
coffee -m -b -c *.coffee
cd services
coffee -m -b -c *.coffee