#!/bin/bash
# Quake backup script based on Alina's script
# Improvements include bugfixes for dependencies and folders, better instructions,
# automatic recognition of user, and list of folders to skip.
#
#SBATCH --mail-user=fabio.zanini@stanford.edu # Email to which notifications will be sent
#SBATCH --job-name=drive_backup
#SBATCH --ntasks=1                            # Number of cores
#SBATCH -N 1
#SBATCH --cpus-per-task=1
#SBATCH --qos=normal                          # Quality of Service (QOS); think of it as job priority,qos normal is 48 hours
#SBATCH -p quake       		              # Partition to submit to.
#SBATCH --mem=8000                            # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=48:00:00
#SBATCH -o hostname_%j.out                    # File to which STDOUT will be written
#SBATCH -e hostname_%j.err                    # File to which STDERR will be written
#SBATCH --mail-type=END,FAIL                  # Type of email notification- BEGIN,END,FAIL,ALL
module load system
module load go

#go get -u github.com/odeke-em/drive/cmd/drive  # Run once at the beginning
#./go/bin/drive init                            # Run once and follow instructions

username=$(basename $HOME)
drive_exec=$HOME/go/bin/drive
date_stamp=$(date +"%Y%m%d");
skip_folderlist=(anaconda3 go tmp gcc4.9 include lib bin share programs human_genome)

echo "Begin backup onto gdrive"
source_fdn=/oak/stanford/groups/quake/$username
for fdn in $(find ${source_fdn}/* -maxdepth 0 -type d ); do
 fdn_base=$(basename $fdn);
 skip='false'
 for fdn_skip in ${skip_folderlist[*]}; do
   if [ $fdn_base == $fdn_skip ]; then
     skip='true'
     break
   fi
 done
 if [ $skip == 'true' ]; then
   echo "Skipping folder $fdn_base"
 else
   echo "Processing folder $fdn_base ..."
   tar cfz - $fdn | $drive_exec push -force -piped "$fdn_base.$date_stamp.tar.gz"
 fi
done
