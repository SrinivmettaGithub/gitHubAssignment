#!/bin/bash
while read line
do
  status=$line
  break
done < ./status.txt
echo "status in the file status.txt:"$status
if [[ $status != "success" ]]
then
  echo "Not a success"
  exit 1
fi
