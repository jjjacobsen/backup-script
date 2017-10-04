#!/bin/bash

#Purpose = automate backups of important files
#Author = Jonah Jacobsen
#Usage = make sure to mount windows partition then just ./backup

# I want to backup .back_aliases, .bashrc, Documents, and Pictures, everything else is on Dropbox

backup(){
  # dynamically make filename based on current date
  filename=bkp-$(date +%-m)-$(date +%-d)-$(date +%-Y).tar.gz

  dest=/home/jjjacobsen/Documents

  bal=/home/jjjacobsen/.bash_aliases
  brc=/home/jjjacobsen/.bashrc
  doc=/home/jjjacobsen/Documents
  pic=/home/jjjacobsen/Pictures
  windoc="/media/jjjacobsen/Users/Jonah Jacobsen/Documents"
  winpic="/media/jjjacobsen/Users/Jonah Jacobsen/Pictures"

  # compress and build the .tar.gz file
  tar -cvpzf $dest/$filename $bal $brc $doc $pic "$windoc" "$winpic";

  # send data to pi
  rsync -avzhe "ssh -p 4201" $dest/$filename jonah@$1:/media/backups;

  # delete file after sending
  rm $dest/$filename;
}

while true; do
  read -p "Is /dev/sda3 mounted at /media/jjjacobsen? [y/n] " yn
  case $yn in
    [Yy] )
      read -p "Are you at home or away? [home/away] " hw
      case $hw in
        "home" ) echo "Backing up files, this will take a few minutes";
          sleep 3;
          backup (static local ip);
          break;;
        "away" ) echo "Backing up files, this will take a few minutes";
          sleep 3;
          backup (router ip);
          break;;
        * ) echo "Please answer home or away";
      esac
      ;;
    [Nn] ) echo "mount before continuing"; break;;
    * ) echo "Please answer y or n.";;
  esac
done

# extract with: tar xvzf file.tar.gz -C /path/to/extract/dir
# can setup a cron schedule to automate, access by typing: crontab -e
