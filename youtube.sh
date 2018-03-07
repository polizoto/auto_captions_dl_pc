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

# Clean Up Text

for f in *.vtt*; do mv "$f" out.srt; done

# Delete lines until blank line
find ./*.srt -type f -exec sed -i '1,/^$/d' {} \;

# remove angle brackets
find ./*.srt -type f -exec sed -i 's/<[^<>]*>//g' {} \;

# delete lines beginning with 0
find ./*.srt -type f -exec sed -i '/^0/ d' {} \;

# remove empty lines
find ./*.srt -type f -exec sed -i '/^$/d' {} \;

# remove extra spaces
find ./*.srt -type f -exec sed -i 's/[[:space:]]\+/ /g' {} \;

# remove line breaks
find ./*.srt -type f -exec sed -i ':a;N;$!ba;s/\n/ /g' {} \;

# Clean up unicode error related to angle brackets

find ./*.srt -type f -exec sed -i 's/&gt;/>/g' {} \;

# Uncapitalize each word and then capitalize first word in each sentence (for some foreign language files)

# sed -i 's/\(.*\)/\L\1/' out.txt
# sed -i 's/\.\s*./\U&\E/g' out.txt

# replace CONTENTS section of punctuator with transcript

sed -ri "s@CONTENTS@$(cat out.srt)@g" ./punctuate.sh

#  Run punctuator

./punctuate.sh

#  Clean Up Punctuate script (remove transcript data)

sed -i 's@"text=.*"@"text=CONTENTS"@g' ./punctuate.sh

# Clean up Transcript

sed -i 's/\[,\ Music\ \]/\[\ Music\ \]/g' *.txt
sed -i 's/\[\ Music,\ \]/\[\ Music\ \]/g' *.txt

# Remove SRT file

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
