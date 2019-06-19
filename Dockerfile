FROM ubuntu:bionic

MAINTAINER xtlsoft

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list

RUN apt update

# PHP Environment
RUN DEBIAN_FRONTEND=noninteractive apt -y install php php-cli php-mbstring php-mysql php-sqlite3 php-soap php-gd php-xml php-dev php-bcmath php-gmp
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime # tzdata fix
RUN apt -y install composer php-pear
RUN pecl install swoole
RUN echo "extension=swoole" > /etc/php/7.2/cli/conf.d/60-swoole.ini
RUN apt source libcurl4-openssl-dev
RUN cd curl-7.58.0 && ./configure && make && make install && cd / && rm ./curl_* -Rf
RUN pecl install yar
RUN echo "extension=yar" > /etc/php/7.2/cli/conf.d/70-yar.ini
RUN apt -y install php-zip
RUN composer config -g repo.packagist composer https://packagist.laravel-china.org
RUN composer g require psy/psysh:@stable

# Golang Environment
RUN apt -y install golang
RUN mkdir /opt/gopath/
ENV GOPATH /opt/gopath/
ENV GOPROXY https://goproxy.cn/

# Docker Environment
RUN apt -y install docker docker-compose

# VIM & tmux & htop ...
RUN apt -y install tree htop tmux vim aptitude zsh wget nano

# Rust Environment
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN apt -y install npm node-gyp nodejs-dev libssl1.0-dev
RUN npm install --global pure-prompt
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN touch ~/.z
RUN sed -i "s/plugins=(git)/plugins=(git\ncommand-not-found\nz\nzsh-autosuggestions\nzsh-syntax-highlighting\n)/g" ~/.zshrc
RUN echo "fpath+=( "~/.zfunctions" $fpath )" >> ~/.zshrc && mkdir ~/.zfunctions
RUN git clone https://github.com/sindresorhus/pure ~/.oh-my-zsh/custom/pure && cd ~/.oh-my-zsh/custom/pure/ && ln -s "$PWD/pure.zsh" "$HOME/.zfunctions/prompt_pure_setup" && ln -s "$PWD/async.zsh" "$HOME/.zfunctions/async"
RUN echo "autoload -U promptinit; promptinit\nprompt pure" >> ~/.zshrc
RUN sed -i "s/\"robbyrussell\"/\"\"/g" ~/.zshrc
RUN chsh -s /bin/zsh

RUN apt -y install python python3 python-pip python3-pip

# RUN wget "https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz" -O code.tar.gz && tar -zxvf code.tar.gz && rm code.tar.gz
ADD ./code-server /usr/bin/code-server

RUN apt -y install "inetutils-*" rsync zip unzip curl

RUN mkdir ~/repos/

ADD ./settings.json /root/.local/share/code-server/User/settings.json
ADD ./deal.php /root/.install-ext.php
RUN php ~/.install-ext.php 0 19
RUN php ~/.install-ext.php 20 39
RUN php ~/.install-ext.php 40 59
RUN php ~/.install-ext.php 60 79
RUN php ~/.install-ext.php 80 99
RUN rm ~/.install-ext.php

# Update Golang
RUN wget https://studygolang.com/dl/golang/go1.12.5.linux-amd64.tar.gz -O go.tar.gz && tar -zxvf go.tar.gz && rm go.tar.gz
RUN ln -svf /go/bin/* /usr/bin
ENV GOROOT /go/

ENV PORT 80
ENTRYPOINT /usr/bin/code-server -p $PORT -H ~/repos/