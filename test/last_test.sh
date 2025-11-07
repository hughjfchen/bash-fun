#! /bin/bash

testLastFromList() {
  assertEquals 10 $(list {1..10} | list_last)
  assertEquals 7 $(list 5 6 7 | list_last)
}

testLastFromOneElementList() {
  assertEquals 1 $(list 1 | list_last)
}

testLastFromEmptyList() {
  assertEquals "" "$(list | list_last)"
}

. ./shunit2-init.sh