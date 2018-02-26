#!/bin/bash
homeDir=$( pwd )
trashSafermDirName=".Trash_saferm"
trashSafermPath="$homeDir/$trashSafermDirName"

rootFile=$1

directoryArray[0]='.'

function init(){

	#create trash dir
	if ! isDir $trashSafermPath; then
        mkdir "$trashSafermPath"
    fi

    #todo: handle invalid

    if [[ ! -d "$rootFile" && ! -f "$rootFile" ]]; then
    	handleError "error in command"
    	handleError "usage: saferm file"
    	exit
    fi
}

function isDir(){

	if [[ -d $1 ]]; then
        return
    fi

    false
}

function previousDir(){
	#delet last item in array, i.e, the current directory, and set the current directory to the previous one
	unset 'directoryArray[${#directoryArray[@]}-1]'
	currentDir=${directoryArray[$(( ${#directoryArray[*]} - 1 ))]}
}

function handleDir(){

	directoryArray[${#directoryArray[*]}]=$1

	read -p "$1 is directory, do you want to enter?:" res

	if [[ ${res:0:1} == 'y' || ${res:0:1} == 'Y' ]]; then
		#list through each file in current directory
		itemsInDir=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )

		for i in $itemsInDir; do

			processInput "$1/$i"
		done

	else
		#dont want to enter, right? go back to previous dir
		previousDir
	fi

	#at this point, you've finished looking through this dir. ask to delete it.
	handleFile $currentDir

	#whatever you choose, im going back to your old dir.
	previousDir
}

function handleFile(){

	read -p "Delete $1 ?:" res

	if [[ ${res:0:1} == 'y' || ${res:0:1} == 'Y' ]];
	then
		#move the file to trash using current folder path( restore case)
		mv "$1" $trashSafermPath
		true
	else
		false
	fi
}

function processInput(){
	if isDir $1; then
		#handel if is dir
		currentDir=$1
		handleDir $currentDir
	else
		#handle if is file
		handleFile $1
	fi
}

#main
init

processInput $rootFile