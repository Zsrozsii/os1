#!/bin/sh

date=`date +'%Y%m%d%H%M'`
backupPrefix=/share/WORK/Backup/MikroTik/

# day=`date +'%e'`
# if [ $(( day % 3 )) -eq 0 ]; then
#     echo "Start Backup"    
# fi

# Backup output directory
backupDir=$backupPrefix/configBackup/Home/

# Path of SSH key
sshKey=$backupPrefix/keys/id_rsa

# SSH Client command line parameters. NO Need To Modify!
sshParams=" -q -i $sshKey -o ConnectTimeout=10 -o batchMode=yes -o StrictHostKeyChecking=no"


if [ ! -d $backupDir ];
then
    echo "Backup directory ($backupDir) NOT exists!";
    exit -1;
fi

if [ ! -f $sshKey ];
then
    echo "SSH Key ($sshKey) NOT Exists!";
    exit -1;
fi

do_backup(){

    backupHost=$2
    backupName=$3
    sshPort=1922
    sshUser=admin

    if [ -n "$4" ];
    then
        sshPort=$4
    fi

    if [ -n "$5" ];
    then
        sshUser=$5
    fi

    # outFile=$backupName
    outFile=$backupName-$date

    if [ $1 == "export" ];
    then
        command=" export file=$outFile"
        outFileLocal=$outFile.rsc
    else
        command="/system backup save dont-encrypt=yes name=$outFile"
        outFileLocal=$outFile.backup
    fi

    ssh $sshParams -p $sshPort $sshUser@$backupHost $command
    scp $sshParams -P $sshPort $sshUser@$backupHost:$outFileLocal $backupDir/
    chown admin $backupDir/$outFileLocal
    ssh $sshParams -p $sshPort $sshUser@$backupHost file remove $outFile

}

do_clean(){
    rm -f `find $backupDir -type f -mtime +90`
}

# do_backup backup|export remoteHost backupName [ssh port] [ssh username]

do_backup backup Backup_Ip BackupName ssh_port username
do_backup export Export_Ip ExportName ssh_port username


do_clean

