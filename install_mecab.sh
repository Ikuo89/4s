#! /bin/bash -x

which mecab > /dev/null 2>&1
if [ $? -eq 1 ]; then
    cd ~
    wget --no-check-certificate 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -O mecab-0.996.tar.gz
    tar zvxf mecab-0.996.tar.gz
    cd mecab-0.996
    ./configure
    make && sudo make install

    cd ~
    wget  --no-check-certificate 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' -O mecab-ipadic-2.7.0-20070801.tar.gz
    tar zvxf mecab-ipadic-2.7.0-20070801.tar.gz
    cd mecab-ipadic-2.7.0-20070801
    ./configure --with-charset=utf8
    make && sudo make install

    sudo chmod 777 /usr/local/lib/mecab/dic
    echo export MECAB_PATH='/usr/local/lib/libmecab.so.2' >> ~/.bash_profile
    source ~/.bash_profile
fi

cd ~
mkdir -p downloads
cd downloads
rm -rf ./mecab-ipadic-neologd
git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
cd mecab-ipadic-neologd
./bin/install-mecab-ipadic-neologd -n
