با سلام خدمت دوستان

سورس مورگان

آموزش نصب :
ابتدا پیش نیاز ها رو نصب میکنیم:

 sudo apt-get update; sudo apt-get upgrade; sudo apt-get install tmux; sudo apt-get install luarocks; sudo apt-get install screen; sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev; sudo apt-get update; sudo apt-get install; sudo apt-get install upstart-sysv

#سپس با دستورات زیر ربات را نصب میکنیم.

1.ابتدا سورس را با دستور زیر کلون کنید.

git clone https://github.com/morgan-team/morgan-tm

    وارد مسیر‌ زیر میشوید و اطلاعات خواسته شده را پر میکنید .

morgan-Company/Config.lua

    کد های زیر را وارد سرور میکنید.

cd Morgan-Company

chmod +x Morgan

./Morgan install

./Morgan config

./Morgan login

بعد از شما شما میگیره وارد میکنید ...

    یه بار از سرور خارج شید وارد شید ربات لانچ کنید.

cd Morgan-Company  

screen ./Autolaunch

    سپس بعد از لانچ شدن ربات api با اکانت cli استارت کنید

▪️Channel: @morgan_team

▪️Edited By : @shiekh_mamad & kiarash_NASA

▪️Special Thanks From : @morgan_team & @morgan_team
Good Luck :)