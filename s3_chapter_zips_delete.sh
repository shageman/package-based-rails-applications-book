# Make sure the AWS CLI is authorized with an access key
# https://www.msp360.com/resources/blog/how-to-find-your-aws-access-key-id-and-secret-access-key/

# List all files
#aws s3 ls s3://pbra2 --recursive --human-readable --summarize

# set -v
set -e

mkdir -p tmp

aws s3 ls s3://pbra2 --recursive --human-readable > tmp/download_chapter_zips_01

# Get all chapter files
awk '{print $NF}' tmp/download_chapter_zips_01 | grep -v app > tmp/download_chapter_zips_02

# Get all chapter names
gsed 's/\(.*\)-[0-9]*\.tgz/\1/g' < tmp/download_chapter_zips_02 | uniq > tmp/download_chapter_zips_03

while read chaptername; do
  echo "Deleting ${chaptername}..."
  LATEST_FILE=`cat tmp/download_chapter_zips_02 | grep $chaptername | sort -r | head -n 1`
  echo "Keeping $LATEST_FILE"

  OLD_FILES=`cat tmp/download_chapter_zips_02 | grep $chaptername | sort -r | tail -n +2`
  for OLDFILE in $OLD_FILES; do
    echo "Deleting $OLDFILE..."
    aws s3 rm s3://pbra2/$OLDFILE
  done
  # aws s3 cp s3://pbra2/$LATEST_FILE docker/minio/data/releases/
done <tmp/download_chapter_zips_03
