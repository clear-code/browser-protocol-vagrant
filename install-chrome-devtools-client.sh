#!/bin/bash

git clone https://github.com/kenhys/cqueues.git
cd cqueues
git checkout -b support-luajit210-with-rockspec origin/support-luajit210-with-rockspec 
luarocks make cqueues-20161215.51-0.rockspec
cd ..

git clone https://github.com/openresty/lua-cjson.git
cd lua-cjson
luarocks make lua-cjson-2.1devel-1.rockspec
cd ..

git clone https://github.com/kenhys/luaossl.git
cd luaossl
git checkout -b support-luajit210-with-rockspec origin/support-luajit210-with-rockspec
luarocks make luaossl-20161214-0.rockspec
cd ..

luarocks install luasocket
luarocks install http
luarocks install chrome-devtools-client

rm -rf ./cqueues
rm -rf ./lua-cjson
rm -rf ./luaossl
