# Launching sandbox
docker run --name devops-sandbox -d ubuntu:latest sleep 10000000
docker exec -it devops-sandbox bash



# Files and directories
pwd

ls
ls -la
ls -laStX

cd
cd /path/to/dir
cd -
cd ../

mkdir new_dir
mkdir -p new_dir/a/b/c

touch file.txt
echo "My first file!" > file.txt
echo "More text!" >> file.txt
cat file.txt
cat file.txt | grep "first"
rm file.txt

echo "wow" > file1
cp file1 new_dir/a/
mv file1 new_dir/a/b



# Env vars
env
echo $HOSTNAME
export COURSE=DevOpsExperts
echo $COURSE

echo $?
# https://www.redhat.com/en/blog/exit-codes-demystified



# Installing packages
apt update
apt install less vim



# Playing with logs
cd /var/log
less dpkg.log
cat dpkg.log | grep "status installed"
cat dpkg.log | grep "status installed" | awk '{print $5}'
cat dpkg.log | grep "status installed" | awk '{print $5}' | cut -d':' -f1
