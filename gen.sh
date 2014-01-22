#!/bin/bash
# simple script to generate test files
# usefull for developpment only

for i in {a..f}
do
	# your environnment variables may vary, this was tested on puppy Linux
	# for instance it could be `date` and $LOGNAME on Ubuntu
	echo "File number $i created on $DATE by $OWNER" >> $i.txt
done
