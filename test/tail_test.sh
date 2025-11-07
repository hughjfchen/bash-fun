#! /bin/bash

testLTailFrom10() {
  assertEquals "2 3 4 5 6 7 8 9 10" "$(list {1..10} | list_tail | unlist)"
}

testLTailFromOneElementList() {
  assertEquals "" "$(list 1 | list_tail)"
}

testLTailFromEmptyList() {
  assertEquals "" "$(list | list_tail)"
}

. ./shunit2-init.sh
