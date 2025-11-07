#! /bin/bash

testPrependToEmptyList() {
  assertEquals 4 "$(list | list_prepend 4)"
}

testPrependToOneElementList() {
  assertEquals "4 1" "$(list 1 | list_prepend 4 | unlist)"
}

testPrependToList() {
  assertEquals "4 1 2 3 4 5" "$(list 1 2 3 4 5 | list_prepend 4 | unlist)"
}

. ./shunit2-init.sh