# Introduction

This is a fork of [ssledz's fun.sh library](https://github.com/ssledz/bash-fun).

This is mainly for my own personal use cases. So I would recommend using ssledz's version instead.
I mainly worked towards getting this library to mostly pass shellcheck, removed some functionality,
and name deconflicted some of the functions with what I had in my system.
# Quick start

```bash
#!/bin/bash
. <(test -e fun.sh || curl -Ls https://raw.githubusercontent.com/brandon-rozek/bash-fun/master/src/fun.sh > fun.sh; cat fun.sh)

seq 1 4 | sum
```

# Functions overview
|||||||
|------|------|------|------|------|------|
|**list_append**|**divide**|**take_while**|
|**list_drop**|**drop_while**|**factorial**|**filter**|**foldl**|
|**isint**|**isempty**|**isfile**|**isnonzerofile**|**isreadable**|**iswritable**|
|**isdir**|**list_join**|**lambda**|**list_last**|**list_head**|**list**|
|**list_tail**|**list_zip**|**list_map**|
|**mod**|**multiply**|**not**|
|**add**|**list_prepend**|**product**|**ret**|
|**revers**|**revers_str**|**scanl**|**splitc**|**strip**|
|**stripl**|**stripr**|**subtract**|**sum**|**take**|
|**tup**|**unlist**|**λ**|


## *list/unlist*

```bash
$ list 1 2 3
1
2
3

$ list 1 2 3 4 5 | unlist
1 2 3 4 5
```

## *list_take/list_drop/list_tail/list_head/list_last*

```bash
$ list 1 2 3 4 | list_drop 2
3
4

$ list 1 2 3 4 5 | list_head
1

$ list 1 2 3 4 | list_tail
2
3
4

$ list 1 2 3 4 5 | list_last
5

$ list 1 2 3 4 5 | list_take 2
1
2
```

## *join*

```bash
$ list 1 2 3 4 5 | list_join ,
1,2,3,4,5
```

## *map*

```bash
$ seq 1 5 | list_map λ a . 'echo $((a + 5))'
6
7
8
9
10

$ list a b s d e | list_map λ a . 'echo $a$(echo $a | tr a-z A-Z)'
aA
bB
sS
dD
eE

$ list 1 2 3 | list_map tee
1
2
3
```
## *filter*

```bash
$ seq 1 10 | filter even
2
4
6
8
10
```

## *foldl/foldr*

```bash
$ list a b c d | foldl λ acc el . 'echo -n $acc-$el'
a-b-c-d
```

```bash
$ seq 1 4 | foldl λ acc el . 'echo $(($acc + $el))'
10
```

```bash
$ seq 1 4 | foldl λ acc el . 'echo $(multiply $(($acc + 1)) $el)'
64 # 1 + (1 + 1) * 2 + (4 + 1) * 3 + (15 + 1) * 4 = 64
```

## *tup/tupx/tupl/tupr*

```bash
$ tup a 1
(a,1)

$ tup 'foo bar' 1 'one' 2
(foo bar,1,one,2)

$ tup , 1 3
(,,1,3)
```

```bash
$ echo tup a 1 | tupl
a

$ echo tup a 1 | tupr
1

$ tup 'foo bar' 1 'one' 2 | tupl
foo bar

$ tup 'foo bar' 1 'one' 2 | tupr
2
```

## *list_zip*

```bash
$ list a b c d e f | list_zip $(seq 1 10)
(a,1)
(b,2)
(c,3)
(d,4)
(e,5)
(f,6)
```

```bash
$ list a b c d e f | list_zip $(seq 1 10) | list_last | tupr
6
```

## *not/isint/isempty*

```bash
$ isint 42
true

$ list blah | isint
false

$ not true
false

$ not "isint 777"
false

$ list 1 2 "" c d 6 | filter λ a . 'isint $a'
1
2
6

$ list 1 2 "" c d 6 | filter λ a . 'not "isempty $a"'
1
2
c
d
6
```

## *isfile/isnonzerofile/isreadable/iswritable/isdir*

```bash
$ touch /tmp/foo

$ isfile /tmp/foo
true

$ not iswritable /
true

$ files="/etc/passwd /etc/sudoers /tmp /tmp/foo /no_such_file"

$ list $files | filter λ a . 'isfile $a'
/etc/passwd
/etc/sudoers
/tmp/foo

$ list $files | filter λ a . 'isdir $a'
/tmp

$ list $files | filter λ a . 'isreadable $a'
/etc/passwd
/tmp
/tmp/foo

$ list $files | filter λ a . 'iswritable $a'
/tmp
/tmp/foo

$ list $files | filter λ a . 'isnonzerofile $a'
/etc/passwd
/etc/sudoers
/tmp

$ list $files | filter λ a . 'not isfile $a'
/tmp
/no_such_file
```
## *scanl*

```bash
$ seq 1 5 | scanl lambda acc el . 'echo $(($acc + $el))'
1
3
6
10
15
```

```bash
$ seq 1 5 | scanl lambda a b . 'echo $(($a + $b))' | list_last
15
```

# Examples

```bash
processNames() {

  uppercase() {
     local str=$1
     echo $(tr 'a-z' 'A-Z' <<< ${str:0:1})${str:1}
  }

  list $@ \
    | filter λ name . '[[ ${#name} -gt 1 ]] && ret true || ret false' \
    | list_map λ name . 'uppercase $name' \
    | foldl λ acc el . 'echo $acc,$el'

}

processNames adam monika s slawek d daniel Bartek j k
```

```bash
Adam,Monika,Slawek,Daniel,Bartek
```

# Running tests
TODO: Need to change the tests here
```bash
cd test
./test_runner
```

# Contribution guidelines

Feel free to ask questions in chat, open issues, or contribute by creating pull requests.

In order to create a pull request
* checkout master branch
* introduce your changes & bump version
* submit pull request

# Resources
* [Inspiration](https://quasimal.com/posts/2012-05-21-funsh.html)
* [Functional Programming in Bash](https://medium.com/@joydeepubuntu/functional-programming-in-bash-145b6db336b7)
