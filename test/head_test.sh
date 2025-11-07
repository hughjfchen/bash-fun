#! /bin/bash

testLHeadFromList() {
  assertEquals 1 $(list {1..10} | list_head)
  assertEquals 5 $(list 5 6 7 | list_head)
}

testLHeadFromOneElementList() {
  assertEquals 1 $(list 1 | list_head)
}

testLHeadFromEmptyList() {
  assertEquals "" "$(list | list_head)"
}

. ./shunit2-init.sh
