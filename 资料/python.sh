yum -y install wget &&
yum -y groupinstall "Development tools" &&
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel &&
wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tar.xz &&
mkdir /usr/local/python3 &&
tar -xvJf  Python-3.7.5.tar.xz &&
cd Python-3.7.5 &&
./configure --prefix=/usr/local/python3 &&
make && make install &&
ln -s /usr/local/python3/bin/python3 /usr/bin/python3 &&
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3 &&
sudo yum -y install epel-release &&
sudo yum -y install python-pip
