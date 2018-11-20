#!/bin/sh
set -e

MONGO_DB_NAME="sit-opsserver"
TIMESTAMP=$(date +"%Y-%m-%d")
MONGO_CLUSTER="$1/$2:27017,$3:27017,$4:27017"


# command to download the latest production snapshot
aws s3 cp s3://chefsplate-devops/opsserver-backups/Daily/`aws s3 ls s3://chefsplate-devops/opsserver-backups/Daily/ | sort -r | cut -d ' ' -f 5 | head -n 1` .
BACKUPFILE=`aws s3 ls s3://chefsplate-devops/opsserver-backups/Daily/ | sort -r | cut -d ' ' -f 5 | head -n 1`
if [ $? -eq 0 ]; then
  #successful
  echo "dumped out from production successful"
else
  #fail
  echo "failed to dump from production cluster"
  exit 1
fi

#Get app keys and apicollection
aws s3 sync s3://chefsplate-devops/apiKeysCollection/Staging/ ./
restoretosit=$(mongorestore --verbose --host $MONGO_CLUSTER -d $MONGO_DB_NAME  --nsInclude 'opsserver-main.*' --nsExclude 'opsserver-main.app' --nsExclude 'opsserver-main.apikeys' --nsExclude 'opsserver-main.deliveries' --nsExclude 'opsserver-main.customers' --nsFrom='opsserver-main.*' --nsTo='sit-opsserver.*' --drop --maintainInsertionOrder --gzip --archive=$BACKUPFILE)
mongoimport --host $MONGO_CLUSTER -d $MONGO_DB_NAME --collection apikeys --file apikeys.json
mongoimport --host $MONGO_CLUSTER -d $MONGO_DB_NAME --collection app --file app.json

echo "Removing Backup file"

rm $BACKUPFILE
echo "Finished"
