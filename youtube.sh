#!/bin/bash
#
# Downloads YouTube captions and cleans them up (makes them a text file and adds punctuation)
# requires that there are no text files in current working directory
# depenendcies: youTube-dl, sed, rm, cat
# Usage: path_to_youtube.sh YouTubeURL

for file in "$@"

do
  extension="${file##*.}"
  basename=`basename "$file" .$extension`
  newfile="$basename.txt"
  
# Step 1
# If you don't have the audio file remove "skip download" options

'C:\Python27\Scripts\youtube-dl.exe' -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' --write-auto-sub "$@"

# youtube-dl --write-auto-sub --skip-download "$@"

# Step 2

'C:\Python27\Scripts\aeneas_convert_syncmap.py' *.vtt out.srt

# Clean Up
rm *.vtt

## Step #3
# remove angle brackets

sed -i 's/<[^<>]*>//g' out.srt

## Step #4 
# Remove spaces 

sed -i '/^\s*$/d' out.srt

# Step #5
# Remove all lines that begin with a zero (video must be < 1 hour)

sed -i '/^0/ d' out.srt

# Step #6 
# Delete every odd number line

sed -i -n '1~2!p' out.srt

# Step Step #7 
# Remove line breaks

sed -i ':a;N;$!ba;s/\n/ /g' out.srt

# Step #8
# Clean up unicode error related to angle brackets

sed -i 's/&gt;/>/g' out.srt

# Step #9
# Uncapitalize each word and then capitalize first word in each sentence (for some foreign language files)

# sed -i 's/\(.*\)/\L\1/' out.txt
# sed -i 's/\.\s*./\U&\E/g' out.txt

# Step #10 replace CONTENTS section of punctuator with transcript

sed -ri "s@CONTENTS@$(cat out.srt)@g" ./punctuate.sh

# Step #11 Run punctuator

./punctuate.sh

# Step # 15 Clean Up Punctuate script (remove transcript data)

sed -i 's@"text=.*"@"text=CONTENTS"@g' ./punctuate.sh

# Step # 16 Clean up Transcript

sed -i 's/\[,\ Music\ \]/\[\ Music\ \]/g' *.txt
sed -i 's/\[\ Music,\ \]/\[\ Music\ \]/g' *.txt

# #Step #17 Remove SRT file

rm out.srt

# Remove YouTube URL
for f in *-**; do mv "$f" "${f//-*/.mp4}"; done

# Send name of MP4 to text file
ls *.mp4 > test2.txt
sed -i 's/.mp4/.txt/g' test2.txt

# Rename Transcript file

cat test2.txt|mv "out.txt" "${f//out.txt/@}"

# Clean up transcript name file
for f in *-**; do mv "$f" "${f//-*/.txt}"; done

# Remove old file
rm test2.txt
done
