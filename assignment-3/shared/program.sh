#!/bin/bash

PRGPATH=$0
MYID=$1
HOST=$2

# empty $MYID means root process
if [[ -z $MYID ]]; then
  MYID=0
  WORK_DIR=$(cd "$(dirname $0)" && pwd)
  PRGPATH=$WORK_DIR/$(basename $0)
  echo $PRGPATH
fi

die() {
  echo $@ >&2
  exit 1
}

##### process spawning #####
if [[ $MYID == 0 ]]; then
  [[ -f "$WORK_DIR/hostfile" ]]||
  die "can not find hostfile on $WORK_DIR/"
  # first line is root
  CID=0
  for h in $(cat "$WORK_DIR/hostfile"); do
    if [[ $CID == 0 ]]; then
      HOST=$h
    else
      ssh $h $PRGPATH $CID $h &
    fi
    CID=$(( $CID + 1 ))
  done
fi
###########################

###### parallel program body ######
cd $(dirname $PRGPATH)
NHOST=$(cat hostfile|wc -l)
MYSLOT=runid.$MYID.$HOST
echo running > $MYSLOT

# do something in all processes
for ((a=1;a<100;a++)); do
  echo $a
  sleep 0.5
done >> $MYSLOT

echo finished >> $MYSLOT
####################################