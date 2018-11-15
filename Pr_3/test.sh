#!/bin/bash

arr=( 1 2 3 )
NIteraciones=2

declare -a 'arr=( "${arr[@]/%//$NIteraciones}" )'

echo "arr: ${arr[*]}"
