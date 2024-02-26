#!/bin/sh
#this is my second script, I'm learning
#
#

echo $1 #writefile1
echo $2 #writestr1

#echo "Welcome to AESD writer!"
#read -p "What is the full filepath (including filename and extension) of the txt file? " writefile1
#read -p "..and what would you like to write there? " writestr1

# should I not prompt the user for inputs??
if [ -z "$1" ];
	then 
	echo "You failed to specify the parameters correctly!"
	return 1
elif [ -z "$2" ];
	then 
	echo "You failed to specify the parameters correctly!"
	return 1
fi



#first check if file exists, then overwrite file (could combine this with an OR statement in the if conditions for conditions in
if [ -f "$1" ];
	then
	#echo "yes1" test
	echo "$2" > "$1"
#2nd check if directory exists, then create new file
elif [ -d "$(dirname $1)" ];
	then
	#echo "yes2"
	cd "$(dirname $1)"
	echo "$2" > "$1"
#3rd check if user input can be a directory, then create directory and file
elif [ ! -d "$(dirname $1)" ];
	then
	#echo "yes3"
	mkdir -p "$(dirname $1)" && touch "$1"
	echo "$2" > "$1"
#otherwise assume an error
else
	echo "Error: Directory could not be created "
	return 1
fi

#echo "Thank you for using AESD writer. "
#return 0


