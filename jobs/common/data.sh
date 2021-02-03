#/bin/bash

function setCurrent {

  temp=$(pwd)
  [ "$temp" = "$current_dir" ] && return

  #[ -z $1 ] && echo "setting current dir to $(pwd)..." >> $data_log || echo "[ $1 ] setting current dir to $(pwd)..." >> $data_log
  startdir=$(pwd)
}
export -f setCurrent

function gotoCurrent {

  temp=$(pwd)
  [ "$temp" = "$current_dir" ] && return

  #echo "changing dir to $startdir..." >> $data_log
  cd "$current_dir" >> $data_log
  #pwd >> $data_log
}
export -f gotoCurrent

function useNamedData {

  #echo "changing dir to $data_dir..." >> $data_log
  cd "$data_dir"
  [ ! -e "_$1" ] && mkdir "_$1" >> $data_log
  #echo "changing dir to _$1..." >> $data_log
  cd "_$1" >> $data_log
  #pwd >> $data_log
}
export -f useNamedData

function initializeDataStore {

  [ -d "$data_dir" ] && return

  echo "Allocating Storage..."

  cd ~/bin >> $data_log
  mkdir data >> $data_log
  cd -
}
export -f initializeDataStore

function clearKeys {

  setCurrent "clearKeys"

  initializeDataStore

  cd "$data_dir"
  [ ! -z $1 ] &&  useNamedData "$1"

  for folder in *; do
    [[ "$folder" == $underscore* ]] && continue
    rm -rf "$folder"
  done

  [ ! -z $1 ] && cd .. && rm -rf "_$1"

  gotoCurrent
}
export -f clearKeys

function getKeys {

  setCurrent "getKeys"
  initializeDataStore

  cd "$data_dir"
  [ ! -z $1 ] && useNamedData "$1"

  for folder in *; do
    [[ "$folder" == $underscore* ]] && continue
    [ -d "$folder" ] && echo "$folder"
  done

  gotoCurrent

}
export -f getKeys

function getCategories {

  setCurrent "getKeys"
  initializeDataStore

  cd "$data_dir"
  [ ! -z $1 ] && useNamedData "$1"

  for folder in *; do
    [[ ! "$folder" == $underscore* ]] && continue
    [ -d "$folder" ] && echo "$folder"
  done

  gotoCurrent

}
export -f getCategories

function getKeyValuePairs {

  setCurrent "getKeyValuePairs"

  initializeDataStore

  [ -z $1 ] && cd "$data_dir" || useNamedData "$1"

  for folder in *; do

    [ ! -d "$folder" ] && continue
    [[ "$folder" == $underscore* ]] && continue

    cd "$folder" >> $data_log
    echo "$folder=$(cat value.txt)"
    cd ..
  done

  gotoCurrent
}
export -f getKeyValuePairs

function getKeyCount {

  result=0
  setCurrent "getKeyCount"

  initializeDataStore

  cd "$data_dir"
  [ ! -z $1 ] && useNamedData "$1"

  for folder in *; do
    [[ "$folder" == $underscore* ]] && continue
    result=$(expr $result + 1)
  done

  gotoCurrent
  echo $result
}

function getValue {

  prefix=
  key="$1"

  pushd "$data_dir" >> $data_log
  [ ! -z "$2" ] && useNamedData "$key" && key="$2"

  if [ -d "$key" ]
  then
    [ ! -z "$2" ] && prefix="$1."
    pushd "$key" >> $data_log
    [ -e value.txt ] && echo "$prefix$key requested, returning "'"'$(cat value.txt)'"' >> $data_log && cat value.txt
    popd >> $data_log
  else
    [ ! -e value.txt ] && echo "$prefix$key requested, returning NULL" >> $data_log
  fi

  popd >> $data_log
}
export -f getValue

function setValue {

  setCurrent "setValue"

  initializeDataStore

  prefix=
  key="$1"
  val="$2"

  cd "$data_dir"
  if [ ! -z "$3" ]
  then
    useNamedData "$1"
    key="$2"
    val="$3"
    prefix="$1."
  fi

  if [ "$val" = "null" ] || [ "$val" = "NULL" ] || [ "$val" = "" ] || [ -z "$val" ]
  then
    echo "resetting $prefix$key" >> $data_log
    [ -d "$key" ] && rm -rf "$key"

  else
    echo "setting $prefix$key = "'"'"$val"'"' >> $data_log

    [ ! -d "$key" ] && mkdir "$key" >> $data_log

    cd "$key" >> $data_log
    #pwd >> $data_log
    [ -f value.txt ] && rm value.txt >> $data_log

    echo "$val" > value.txt
  fi

  gotoCurrent
}
export -f setValue

function valueExists {

    setCurrent "valueExists"
    initializeDataStore

    result=false

    [ -z $2 ] && cd "$data_dir" || useNamedData "$2"
    [ -d "$1" ] && result=true

    echo $result
    gotoCurrent
}

function getBool {

    setCurrent "getBool"

    initializeDataStore

    [ -z $2 ] && cd "$data_dir" || useNamedData "$2"

    if [ -f "$1.dat" ]
    then
        echo "$1 requested, returning true" >> $data_log
        echo "true"

    else
        echo "$1 requested, returning false" >> $data_log
        echo "false"
    fi

    gotoCurrent
}
export -f getBool

function setBool {

    setCurrent "setBool"

    initializeDataStore

    [ -z $3 ] && cd "$data_dir" || useNamedData "$3"

    if [ "$2" = "TRUE" ] || [ "$2" = "true" ] || [ "$2" = "TRUE" ] || [ "$2" = "true" ]
    then
        echo "setting $1=true" >> $data_log
        touch "$1.dat" >> $data_log

    else
        echo "setting $1=false" >> $data_log
        [ -f "$1.dat" ] && rm "$1.dat" >> $data_log
    fi

  gotoCurrent
}
export -f setBool

function runTestSuite {

  clearKeys

  setValue "first name" Mark
  setValue "middle name" "Anthony"
  setValue "last name" 'Pippins'
  setValue gender "male"
  setValue 'height' "5'8"

  setBool "employed" true

  setValue NCIC "Dev" "mpippins"
  setValue NCIC "Business Analyst" Frances

  echo
  echo "keys:"
  getKeys
  echo
  echo "pairs:"
  getKeyValuePairs

  echo
  echo "NCIC keys:"
  getKeys NCIC
  echo
  echo "NCIC pairs:"
  getKeyValuePairs NCIC

  #clearKeys
}
export -f runTestSuite

underscore="_"
data_dir=~/bin/data
data_log=$LOGS/data.log

[[ ! -e $data_dir ]] && mkdir $data_dir

echo "data module loaded."
