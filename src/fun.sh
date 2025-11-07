#!/usr/bin/env bash

drop() {
  command tail -n +$(($1 + 1))
}

take() {
  command head -n ${1}
}

ltail() {
  drop 1
}

lhead() {
  take 1
}

last() {
  command tail -n 1
}

###############################################
## List Functions
###############################################
list() {
    for i in "$@"; do
        echo "$i"
    done
}

unlist() {
    xargs
}

# Drop the first n items of a list.
list_drop() {
    command tail -n +$(($1 + 1))
}

# Take the first n items of a list.
list_take() {
    command head -n "$1"
}

# Take the 'tail' of a list.
# Otherwise known as dropping the first element.
list_tail() {
    list_drop 1
}

# Take only the first element of the list.
list_head() {
    list_take 1
}

# Take the last element of the list.
list_last() {
    command tail -n 1
}

# Add the contents of standard input
# to the end of the list.
list_append() {
    cat -
    list "$@"
}

# Add the contents of standard input
# to the beginning of the list.
list_prepend() {
    list "$@"
    cat -
}

###############################################
## Lambdas and Lists
###############################################
# Defines an anonymous function.
lambda() {
    # shellcheck disable=2039
    local expression
    lam() {
        # shellcheck disable=2039
        local arg
        while [ $# -gt 0 ]; do
            arg="$1"
            shift
            if [ "$arg" = '.' ]; then
                echo "$@"
                return
            else
                echo "read $arg;"
            fi
        done
    }

    expression=$(lam "$@")
    eval "$expression"
}

# Same as lambda.
# shellcheck disable=2039
λ() {
    lambda "$@"
}

# Print the number of arguments a lambda takes.
# shellcheck disable=2039
λ_num_args() {
    # Calculates the number of arguments a lambda takes
    minus "$#" 3
}

# Perform an operation to each
# element(s) of a list provided
# through standard input.
list_map() {
    # shellcheck disable=2039
    local x
    # shellcheck disable=2039
    local i
    # shellcheck disable=2039
    local arguments
    # shellcheck disable=2039
    local num_args
    if [ "$1" = "λ" ] || [ "$1" = "lambda" ]; then
        num_args=$(λ_num_args "$@")
        while read -r x; do
            arguments="$x"
            i=2
            while [ $i -le "$num_args" ] ; do
                read -r x
                arguments="$arguments $x"
                i=$(add $i 1)
            done
            # We want to word split arguments, so no quotes
            eval "list $arguments" | "$@"
        done
    else # Do not know the arity, assume 1
        while read -r x; do
            echo "$x" | "$@"
        done
    fi
}

# Perform a binary operation on a list
# where one element is the accumulation
# of the results so far.
# Ex: seq 3 | foldl lambda a b . 'minus $a $b'
# First is (1 - 2 = -1) then (-1 - 3 = -4).
foldl() {
    # shellcheck disable=2039
    local acc
    read -r acc
    while read -r elem; do
        acc=$({ echo "$acc"; echo "$elem"; } | "$@" )
    done
    echo "$acc"
}

# Constructs a list where each element
# is the foldl of the 0th-ith elements of
# the list.
scanl() {
    # shellcheck disable=2039
    local acc
    read -r acc
    echo "$acc"
    while read -r elem; do
        acc=$({ echo "$acc"; echo "$elem"; } | "$@" )
        echo "$acc"
    done
}

# Drops any elements of the list where the
# function performed on it evaluates to false.
filter() {
    # shellcheck disable=2039
    local x
    while read -r x; do
        ret=$(echo "$x" | "$@")
        if_then "$ret" "echo $x"
    done
}

# Keep taking elements until a certain condition
# is false.
take_while() {
    # shellcheck disable=2039
    local x
    # shellcheck disable=2039
    local condition
    while read -r x; do
        condition="$(echo "$x" | "$@")"
        if_then_else "$condition" "echo $x" "break"
    done
}

# Keep dropping elements until a certain condition
# is false.
drop_while() {
    # shellcheck disable=2039
    local x
    while read -r x; do
        condition="$(echo "$x" | "$@")"
        if_then_else "$condition" 'do_nothing' 'break'
    done
    if_then "[ -n $x ]" "{ echo $x; cat -; }"
}


###############################################
## Arithmetic Functions
###############################################
multiply() {
    # shellcheck disable=2039
    local a
    # shellcheck disable=2039
    local b
    a=$1
    if [ $# -lt 2 ] ; then
        read -r b
    else
        b=$2
    fi
    isint "$a" > /dev/null && \
    isint "$b" > /dev/null && \
    echo $((a * b))
}

add() {
    # shellcheck disable=2039
    local a
    # shellcheck disable=2039
    local b
    a=$1
    if [ $# -lt 2 ] ; then
        read -r b
    else
        b=$2
    fi
    isint "$a" > /dev/null && \
    isint "$b" > /dev/null && \
    echo $((a + b))
}

minus() {
    # shellcheck disable=2039
    local a
    # shellcheck disable=2039
    local b
    a=$1
    if [ $# -lt 2 ] ; then
        b=$1
	read -r a
    else
        b=$2
    fi
    isint "$a" > /dev/null && \
    isint "$b" > /dev/null && \
    echo $((a - b))
}

divide() {
    # shellcheck disable=2039
    local a
    # shellcheck disable=2039
    local b
    a=$1
    if [ $# -lt 2 ] ; then
        b=$1
	read -r a
    else
        b=$2
    fi
    isint "$a" > /dev/null && \
    isint "$b" > /dev/null && \
    echo $((a / b))
}

mod() {
    # shellcheck disable=2039
    local a
    # shellcheck disable=2039
    local b
    a=$1
    if [ $# -lt 2 ] ; then
        b=$1
	read -r a
    else
        b=$2
    fi
    isint "$a" > /dev/null && \
    isint "$b" > /dev/null && \
    echo $((a % b))
}

even() {
    # shellcheck disable=2039
    local n
    # shellcheck disable=2039
    local result
    # shellcheck disable=2039
    local result_code
    if [ $# -lt 1 ] ; then
        read -r n
    else
        n=$1
    fi
    result=$(mod "$n" 2)
    result_code=$?
    if [ $result_code -ne 0 ] ; then
        ret false
    else
        result_to_bool "[ $result = 0 ]"
    fi
}

odd() {
    not even
}

less_than() {
    # shellcheck disable=2039
    local n
    read -r n
    if isint "$n" > /dev/null && \
       [ "$n" -lt "$1" ] ; then
        ret true
    else
        ret false
    fi
}

sum() {
    foldl lambda a b . "add \$a \$b"
}

product() {
    foldl lambda a b . "multiply \$a \$b"
}

factorial() {
    seq 1 "$1" | product
}

###############################################
## String Operations
###############################################
# Splits a string into a list where each element
# is one character.
splitc() {
    sed 's/./\n&/g' | list_tail
}

# Takes a list and creates a string where
# each element is seperated by a delimiter.
list_join() {
    # shellcheck disable=2039
    local delim
    delim=$1
    foldl lambda a b . "echo \$a$delim\$b"
}

# Split a string into a list
# by a specified delimeter
str_split() {
    sed "s/$1/\n/g"
}

# Reverses a list.
revers() {
    # shellcheck disable=2039
    local result
    # shellcheck disable=2039
    local n
    while read -r n; do
        result="$n\n$result"
    done
    echo "$result"
}

# Reverses a string
revers_str() {
    splitc | revers | list_join
}

# Removes multiple occurences of
# a single character from the beginning
# of the list.
lstrip() {
    # shellcheck disable=2039
    local c
    if [ $# -eq 0 ] ; then
        c=" "
    else
        c="$1"
    fi
    sed "s/^$c*//g"
}

# Removes multiple occurences of
# a single character from the end
# of the list.
rstrip() {
    # shellcheck disable=2039
    local c
    if [ $# -eq 0 ] ; then
        c=" "
    else
        c="$1"
    fi
    sed "s/$c*$//g"
}

# Removes multiple occurences of
# a single character from the beginning
# and end of the list.
strip() {
    lstrip "$@" | rstrip "$@"
}

###############################################
## Tuple Functions
###############################################

# Creates a tuple, which is a string with
# multiple elements seperated by a comma,
# and it begins with a ( and ends with a ).
tup() {
    # shellcheck disable=2039
    local args
    # shellcheck disable=2039
    local result
    if [ $# -eq 0 ]; then
        args=$(unlist)
        eval "tup $args"
    else
        result=$(list "$@" | list_join ,)
        echo "($result)"
    fi
}

# Takes a tuple and outputs it as a list
tup_to_list() {
    local li
    local f
    local la
    li=$(str_split ",")

    # Remove '(' from the first element
    f=$(echo "$li" | list_head)
    f=$(echo "$f" | sed 's/^(//')

    la=$(echo "$li" | list_last)
    # If there is only one element in the list
    # Remove ')' from the only element
    if [ "$(echo "$la" | cut -c1)" = "(" ]; then
        f=$(echo "$f" | sed "s/)$//")
        echo "$f"
    # If there is more than one element in the list
    # Remove ')' from the last element
    else
        la=$(echo "$la" | sed "s/)$//")
        # Remove the first and last element from li
        li=$(echo "$li" | list_tail | sed '$d')
        # Print the list
        { echo "$f"; echo "$li"; echo "$la"; }
    fi
}

# Takes the first element of the tuple
tupl() {
    tup_to_list | list_head
}

# Takes the last element of the tuple
tupr() {
    tup_to_list | list_last
}


# Takes each element from a list in standard
# input and matches it with a list provided
# as the argument to this function.
# The result is a list of 2-tuples.
list_zip() {
    # shellcheck disable=2039
    local l
    l=$(list "$@")
    while read -r x; do
        y=$(echo "$l" | list_take 1)
        tup "$x" "$y"
        l=$(echo "$l" | list_drop 1)
    done
}

###############################################
## Logic Based Functions
###############################################

if_then() {
    # shellcheck disable=2039
    local result
    eval "$1"
    result=$?
    if [ $result -eq 0 ] ; then
        eval "$2"
    fi
}

if_then_else() {
    # shellcheck disable=2039
    local result
    eval "$1"
    result=$?
    if [ $result -eq 0 ] ; then
        eval "$2"
    else
        eval "$3"
    fi
}

result_to_bool() {
    if_then_else "$1" 'ret true' 'ret false'
}

not() {
    if_then_else "$1 > /dev/null" "ret false" "ret true"
}

ret() {
    echo "$@"
    "$@"
}

filter() {
  local x
  while read x; do
    ret=$(echo "$x" | "$@")
    $ret && echo $x
  done
}

pass() {
  echo > /dev/null
}

dropw() {
  local x
  while read x && $(echo "$x" | "$@"); do
    pass
  done
  [[ ! -z $x ]] && { echo $x; cat -; }
}

peek() {
  local x
  while read x; do
    ([ $# -eq 0 ] && 1>&2 echo $x || 1>&2 "$@" < <(echo $x))
    echo $x
  done
}

stripl() {
  local arg=$1
  if [[ $arg == *'['*']'* ]]; then
    arg=$(echo $arg | sed -E 's/\]/\\]/g')
  fi
  cat - | map lambda l . 'ret ${l##'$arg'}'
}

stripr() {
  local arg=$1
  if [[ $arg == *'['*']'* ]]; then
    arg=$(echo $arg | sed -E 's/\]/\\]/g')
  fi
  cat - | map lambda l . 'ret ${l%%'$arg'}'
}

strip() {
  local arg=$1
  cat - | stripl "$arg" | stripr "$arg"
}

buff() {
  local cnt=-1
  for x in $@; do
    [[ $x = '.' ]] && break
    cnt=$(plus $cnt 1)
  done
  local args=''
  local i=$cnt
  while read arg; do
    [[ $i -eq 0 ]] && list $args | "$@" && i=$cnt && args=''
    args="$args $arg"
    i=$(sub $i 1)
  done
  [[ ! -z $args ]] && list $args | "$@"
}

tup() {
  if [[ $# -eq 0 ]]; then
    local arg
    read arg
    tup $arg
  else
    list "$@" | map lambda x . 'echo ${x//,/u002c}' | join , '(' ')'
  fi
}

tupx() {
  if [[ $# -eq 1 ]]; then
    local arg
    read arg
    tupx "$1" "$arg"
  else
    local n=$1
    shift
    echo "$@" | stripl '(' | stripr ')' | cut -d',' -f${n} | tr ',' '\n' | map lambda x . 'echo ${x//u002c/,}'
  fi
}

tupl() {
  tupx 1 "$@"
}

tupr() {
  tupx 1- "$@" | last
}

ntup() {
  if [[ $# -eq 0 ]]; then
    local arg
    read arg
    ntup $arg
  else
    list "$@" | map lambda x . 'echo "$x" | base64 --wrap=0 ; echo' | join , '(' ')'
  fi
}

ntupx() {
  if [[ $# -eq 1 ]]; then
    local arg
    read arg
    ntupx "$1" "$arg"
  else
    local n=$1
    shift
    echo "$@" | stripl '(' | stripr ')' | cut -d',' -f${n} | tr , '\n' | map lambda x . 'echo "$x" | base64 -d'
  fi
}

ntupl() {
  ntupx 1 "$@"
}

ntupr() {
  ntupx 1- "$@" | last
}

lzip() {
  local list=$*
  cat - | while read x; do
    y=$(list $list | take 1)
    tup $x $y
    list=$(list $list | drop 1)
  done
}

curry() {
  exportfun=$1; shift
  fun=$1; shift
  params=$*
  cmd=$"function $exportfun() {
      more_params=\$*;
      $fun $params \$more_params;
  }"
  eval $cmd
}

with_trampoline() {
  local f=$1; shift
  local args=$@
  while [[ $f != 'None' ]]; do
    ret=$($f $args)
#    echo $ret
    f=$(tupl $ret)
    args=$(echo $ret | tupx 2- | tr ',' ' ')
  done
  echo $args
}

res() {
    local value=$1
    tup "None" $value
}

call() {
    local f=$1; shift
    local args=$@
    tup $f $args
}

maybe() {
  if [[ $# -eq 0 ]]; then
    local arg
    read arg
    maybe "$arg"
  else
    local x="$*"
    local value=$(echo $x | strip)
    if [[ ${#value} -eq 0 ]]; then
      tup Nothing
    else
      tup Just "$value"
    fi
  fi
}

maybemap() {
  local x
  read x
  if [[ $(tupl $x) = "Nothing" ]]; then
    echo $x
  else
    local y=$(tupr "$x")
    local r=$(echo "$y" | map "$@")
    maybe "$r"
  fi
}

maybevalue() {
  local default="$*"
  local x
  read x
  if [[ $(tupl $x) = "Nothing" ]]; then
      echo "$default"
  else
      echo $(tupr $x)
  fi
}


###############################################
## Useful utility functions
###############################################

isint() {
    result_to_bool "echo \"$1\" | grep -Eq '^-?[0-9]+$'"
}

isempty() {
    result_to_bool "[ -z \"$1\" ]"
}

isfile() {
    result_to_bool "[ -f \"$1\" ]"
}

isnonzerofile() {
    result_to_bool "[ -s \"$1\" ]"
}

isreadable() {
    result_to_bool "[ -r \"$1\" ]"
}

iswritable() {
    result_to_bool "[ -w \"$1\" ]"
}

isdir() {
    result_to_bool "[ -d \"$1\" ]"
}
