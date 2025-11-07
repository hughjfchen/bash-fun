#! /bin/bash

testTupIfEmpty() {
  assertEquals '()' $(tup '')
}

testTupIfOneElement() {
  assertEquals '(1)' $(tup 1)
  assertEquals '(")' $(tup '"')
  assertEquals "(')" $(tup "'")
  assertEquals "(,)" $(tup ",")
  assertEquals "(,,)" $(tup ",,")
  assertEquals "(()" $(tup "(")
  assertEquals "())" $(tup ")")
}

testTupHappyPath() {
  assertEquals '(1,2,3,4,5)' $(tup 1 2 3 4 5)
  assertEquals '(a-1,b-2,c-3)' $(tup 'a-1' 'b-2' 'c-3')
  assertEquals '(a b,c d e,f)' "$(tup 'a b' 'c d e' 'f')"
}

testTupxIfZeroIndex() {
  assertEquals '' "$(tup 1 3 | tupx 0 2>/dev/null)"
}

testTupl() {
  assertEquals '4' "$(tup 4 5 | tupl)"
  assertEquals '4' "$(tup 4 5 6 | tupl)"
  assertEquals '6' "$(tup 6 | tupl)"
  assertEquals 'foo bar' "$(tup 'foo bar' 1 'one' 2 | tupl)"
}

testTupr() {
  assertEquals '5' "$(tup 4 5 | tupr)"
  assertEquals '5' "$(tup 1 4 5 | tupr)"
  assertEquals '5' "$(tup 5 | tupr)"
}

. ./shunit2-init.sh
