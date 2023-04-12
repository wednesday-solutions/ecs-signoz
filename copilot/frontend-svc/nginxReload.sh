#!/bin/bash

i=0

while [ $i -lt 12 ]; do # 12 five-second intervals in 1 minute
  sleep 5
  nginx -s reload  
  
  i=$(( i + 1 ))
done

