#!/bin/bash

function generateLoremIpsum {
  curl -s -X POST lipsum.com/feed/json -d "amount=$1" -d "what=para" -d"start=$2" | jq -r '.feed.lipsum'
}

function randomDate {
  LBOUND="01/01/2010 00:00:00 UTC"
  UBOUND="01/18/2016 00:00:00 UTC"
  LBSECS=$(gdate --date="$LBOUND" +%s)
  UBSECS=$(gdate --date="$UBOUND" +%s)
  DIFF=$(($UBSECS - $LBSECS))
  RND=$(gshuf -i 1-$DIFF -n 1)
  NEWDATE=$(($LBSECS + $RND))
  gdate -d "@$NEWDATE" --rfc-2822
}

function generatePost {
  printf "%s\n" "---"
  printf "%s\n" "date: $1"
  printf "%s\n" "slug: $2"
  printf "%s\n" "title: $3"
  printf "%s\n" "published: $4"
  printf "%s\n" "---"
  printf "%s\n" "$5"
}

function trueOrFalse {
  RND=$(gshuf -i 0-100 -n 1)
  if [[ $RND -gt 20 ]]; then
    echo "true"
  else
    echo "false"
  fi
}

if [[ `pwd` == *bin ]]; then

  MAX=100
  for i in `seq 1 $MAX`;
  do
    LOREM=$(generateLoremIpsum 1 $i)
    TITLE=$(echo $LOREM | cut -d' ' -f1-4)
    SLUG=$(./slugify.sh -x -l "$TITLE")
    DATE=$(randomDate)
    PUBLISHED=$(trueOrFalse)
    POST=$(generatePost "$DATE" "$SLUG" "$TITLE" "$PUBLISHED" "$LOREM")

    echo "$POST" > "../workspace/posts/$SLUG.md"
    echo "[$i/$MAX] Generated $SLUG ..."
  done
else
  echo "error: run from bin directory"
fi
