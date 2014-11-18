all:
	$(info 'Nothing todo!')
	$(info 'Use make install or make uninstall')

dep-ubuntu:
	apt-get install ruby ruby-highline ruby-i18n ruby-locale ruby-colorize

configure:
	gem install bundler
	bundle install

install:
	mkdir -p /usr/local/todo-cli
	cp -r ./lib /usr/local/todo-cli/
	cp -r ./i18n /usr/local/todo-cli/
	cp ./todo-cli /usr/local/todo-cli/
	ln -snf /usr/local/todo-cli/todo-cli /usr/local/bin/

uninstall:
	rm /usr/local/bin/todo-cli
	rm -rf /usr/local/todo-cli
