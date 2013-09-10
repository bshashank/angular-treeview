#!/bin/bash
rm -rf build
mkdir build
coffee -o build -c src/angular-treeview.coffee
scss src/angular-treeview.scss > build/angular-treeview.css
cp src/angular-treeview-arrows.png build/angular-treeview-arrows.png