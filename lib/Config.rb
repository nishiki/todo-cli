#!/usr/bin/ruby
# author: nishiki
# mail: nishiki@yaegashi.fr
# info: a simple script who manage your passwords

module TodoCli

	require 'rubygems'
	require 'yaml'
	require 'i18n'
	
	class Config
		
		attr_accessor :error_msg
	
		attr_accessor :lang
		attr_accessor :deadline_limit
		attr_accessor :last_update
		attr_accessor :sync_type
		attr_accessor :sync_host
		attr_accessor :sync_port
		attr_accessor :sync_user
		attr_accessor :sync_pwd
		attr_accessor :sync_path
		attr_accessor :dir_config
	
		# Constructor
		def initialize
			@error_msg  = nil

			if /darwin/ =~ RUBY_PLATFORM
				@dir_config = "#{Dir.home}/Library/Preferences/todo-cli"
			elsif /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
				@dir_config = "#{Dir.home}/AppData/Local/todo-cli"
			else 
				@dir_config = "#{Dir.home}/.config/todo-cli"
			end

			@file_config = "#{@dir_config}/config.yml"
			if not File.exist?(@file_config)
				setup(lang: 'en')
			end
		end
	
		# Create a new config file
		# @args: options -> new config options
		# @rtrn: true if the config file is create
		def setup(options={})

			lang           = options[:lang].nil?           ? @lang           : options[:lang]
			deadline_limit = options[:deadline_limit].nil? ? @deadline_limit : options[:deadline_limit]
			sync_type      = options[:sync_type].nil?      ? @sync_type      : options[:sync_type]
			sync_host      = options[:sync_host].nil?      ? @sync_host      : options[:sync_host]
			sync_port      = options[:sync_port].nil?      ? @sync_port      : options[:sync_port]
			sync_user      = options[:sync_user].nil?      ? @sync_user      : options[:sync_user]
			sync_pwd       = options[:sync_pwd].nil?       ? @sync_pwd       : options[:sync_pwd]
			sync_path      = options[:sync_path].nil?      ? @sync_path      : options[:sync_path]
			last_update    = @last_update.to_s.empty?      ? 0               : @last_update
	
			config = {'config' => {'lang'           => lang,
			                       'deadline_limit' => sync_type,
			                       'sync_type'      => sync_type,
			                       'sync_host'      => sync_host,
			                       'sync_port'      => sync_port,
			                       'sync_user'      => sync_user,
			                       'sync_pwd'       => sync_pwd,
			                       'sync_path'      => sync_path,
			                       'last_update'    => last_update,
			                      }
			         }
	
			File.open(@file_config, 'w') do |file|
				file << config.to_yaml
			end
			
			return true
		rescue Exception => e 
			@error_msg = "#{I18n.t('error.config.write')}\n#{e}"
			return false
		end

		# Check the config file
		# @rtrn: true if the config file is correct
		def checkconfig
			config = YAML::load_file(@file_config)
			@lang           = config['config']['lang']
			@deadline_limit = config['config']['deadline_limit'].to_i * 3600 * 24
			@sync_type      = config['config']['sync_type']
			@sync_host      = config['config']['sync_host']
			@sync_port      = config['config']['sync_port']
			@sync_user      = config['config']['sync_user']
			@sync_pwd       = config['config']['sync_pwd']
			@sync_path      = config['config']['sync_path']
			@last_update    = config['config']['last_update'].to_i

			I18n.locale = @lang.to_sym

			return true
		rescue Exception => e 
			puts e
			@error_msg = "#{I18n.t('error.config.check')}\n#{e}"
			return false
		end

		# Set the last update when there is a sync
		# @rtrn: true is the file has been updated
		def set_last_update
			config = {'config' => {'lang'           => @lang,
			                       'deadline_limit' => @deadline_limit,
			                       'sync_type'      => @sync_type,
			                       'sync_host'      => @sync_host,
			                       'sync_port'      => @sync_port,
			                       'sync_user'      => @sync_user,
			                       'sync_pwd'       => @sync_pwd,
			                       'sync_path'      => @sync_path,
			                       'last_update'    => Time.now.to_i,
			                      }
		             }
	
			File.open(@file_config, 'w') do |file|
				file << config.to_yaml
			end

			return true
		rescue Exception => e 
			@error_msg = "#{I18n.t('error.config.write')}\n#{e}"
			return false
		end
		
	end

end
