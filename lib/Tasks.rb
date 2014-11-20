#!/usr/bin/ruby
# author: nishiki
# mail: nishiki@yaegashi.fr

require 'yaml'
require 'i18n'
require 'time'

class Tasks

	attr_accessor :error_msg

	# Constructor
	def initialize
		@error_msg = nil
		@tasks     = {}
		@file      = 'tasks.yml'

		if /darwin/ =~ RUBY_PLATFORM
			@dir_config = "#{Dir.home}/Library/Preferences/todo-cli"
		elsif /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
			@dir_config = "#{Dir.home}/AppData/Local/todo-cli"
		else 
			@dir_config = "#{Dir.home}/.config/todo-cli"
		end
	end

	# Load data
	# @rtrn: true if there is nothing error
	def load
		@tasks = YAML.load_file("#{@dir_config}/#{@file}") if File.exist?("#{@dir_config}/#{@file}")
		return true
	rescue Exception => e
		@error_msg = "#{I18n.t('error.load')}\n#{e}"
		return false
	end

	# Add a task
	# @args: options -> name, comment, date_deadline
	# @rtrn: false if the id is unknown
	def add(options={})
		if options[:name].to_s.empty?
			@error_msg = I18n.t('error.name_empty')
			return false
		end

		id       = @tasks.empty?           ? 1   : @tasks.to_a.last[0] + 1
		progress = options[:progress].to_i
		progress = 0                              if not progress.between?(0, 100) 
		deadline = Time.parse(options[:deadline]) if not options[:deadline].nil?

		@tasks.merge!({id => {'id'          => id,
		                      'name'        => options[:name],
		                      'deadline'    => deadline,
		                      'progress'    => progress,
		                      'comment'     => options[:comment],
		                      'date_create' => Time.now,
		                     }
		              }
		             )

		return true
	end

	# Remove a task
	# @args: id -> the task's id
	# @rtrn: false if the id is unknown
	def delete(id)
		id = id.to_i

		if not @tasks.has_key?(id)
			@error_msg = I18n.t('error.id_unknown', id: id)
			return false
		end

		@tasks.delete(id)
	end

	# Update a task
	# @args: id -> the task's id
	#        options -> name, comment, date_deadline
	# @rtrn: false if the id is unknown
	def update(id, options={})
		id = id.to_i

		if not @tasks.has_key?(id)
			@error_msg = I18n.t('error.id_unknown', id: id)
			return false
		end

		name     = options[:name].to_s.empty? ? @tasks[id]['name']     : options[:name]
		comment  = options[:comment].nil?     ? @tasks[id]['comment']  : options[:comment]
		progress = options[:progress].nil?    ? @tasks[id]['progress'] : options[:progress]
		deadline = options[:deadline].nil?    ? @tasks[id]['deadline'] : options[:deadline]
		progress = options[:progress].nil?    ? @tasks[id]['progress'] : options[:progress]

		deadline = Time.parse(deadline) if not deadline.to_s.empty?
		progress = 0                    if not progress.to_i.between?(0, 100) 

		@tasks.merge!({id => {'id'          => id,
		                      'name'        => name,
		                      'deadline'    => deadline,
		                      'progress'    => progress,
		                      'comment'     => comment,
		                      'date_create' => @tasks[id]['date_create'],
		                      'date_update' => Time.now,
		                     }
		              }
		             )
		return true
	end

	# Show all information a task
	# @args: id -> the task's id
	# @rtrn: return a hash
	def show(id)
		id = id.to_i
		if not @tasks.has_key?(id)
			@error_msg = I18n.t('error_id.unknown', id: id)
			return {}
		end

		return @tasks[id]
	end

	# List all tasks
	# @rtrn: return an array of hash
	def list
		return @tasks.to_a
	end

	# Save the tasks in file
	# @rtrn: true if there is nothing error
	def save
		Dir.mkdir(@dir_config) if not Dir.exist?(@dir_config)

		File.open("#{@dir_config}/#{@file}", 'w') { |f| f << @tasks.to_yaml }
		return true
	rescue Exception => e
		@error_msg = "#{I18n.t('error.save')}\n#{e}"
		return false
	end
end
