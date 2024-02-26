#!/bin/sh
#this is my first script, wish me luck
#-->> luck
#

#echo $0 #this is the shell file name
echo $1 #this is the first argument filesdir1
echo $2 #second argument searchstr1

#echo "Welcome to AESD finder!"
#read -p "What is the filepath you are seeking to search? " filesdir1
#read -p "..and what is the text string you are searching for? " searchstr1
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


if [ -d "$1" ];
	then
	countx=$(grep -ir "$2" $1 | wc -l )  
	county=$(grep -ilr "$2" $1 | wc -l ) 
	echo "The number of files are ${county} and the number of matching lines are ${countx} "
else
	echo "..no such directory"
	return 1
fi


#echo "Thank you for choosing AESD finder!"
#echo "Have a nice day"
