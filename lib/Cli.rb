#!/usr/bin/ruby
# author: nishiki
# mail: nishiki@yaegashi.fr

require 'time'
require 'colorize'
require 'i18n'
require 'pathname'
require 'command_line_reporter'
include CommandLineReporter
require "#{APP_ROOT}/lib/Tasks"
require "#{APP_ROOT}/lib/Config"

module TodoCli
	class Cli
	
		# Constructor
		def initialize
			@config = TodoCli::Config.new 
			@tasks  = TodoCli::Tasks.new
	
			if not @config.checkconfig
				puts "#{I18n.t('display.error')} #1: #{@tasks.error_msg}"
				exit(3)
			end
	
			if not @tasks.load
				puts "#{I18n.t('display.error')} #1: #{@tasks.error_msg}"
				exit(3)
			end
		end
	
		# Add a new tasks
		# @args: data -> the new task's data
		def add(data={})
			if @tasks.add(data)
				if @tasks.save
					puts I18n.t('success.add').green
				else
					puts "#{I18n.t('display.error')} #2: #{@tasks.error_msg}".red
				end
			else
				puts "#{I18n.t('display.error')} #3: #{@tasks.error_msg}".red
			end
		end
	
		# Show a task
		# @args: id -> the tasks's id
		def show(id)
			task = @tasks.show(id)
			if task.empty?
				puts "#{I18n.t('diplay.error')} #4: #{@tasks.error_msg}".red
			else
				print "##{task['id']} - ".yellow
				print "#{task['name']} - "
		
				print "#{I18n.t('display.group')}: ".yellow
				print "#{task['group']} - "
	
				print "#{I18n.t('display.progress')}: ".yellow
				puts "#{task['progress']}%".send(progress_color(task['progress']))
	
				
				puts '-' * 50
	
				print "#{I18n.t('display.deadline')}: ".yellow
				puts "#{task['deadline']}".send(deadline_color(task['deadline']))
				print "#{I18n.t('display.comment')}: ".yellow
				puts task['comment']
	
				puts '-' * 50
	
				print "#{I18n.t('display.date_create')}: ".yellow
				puts task['date_create']
				print "#{I18n.t('display.date_update')}: ".yellow
				puts task['date_update']
				print "#{I18n.t('display.date_finish')}: ".yellow
				puts task['date_finish']
	
				puts '-' * 50
			end
		end
	
		# Update a task
		# @args: id -> the tasks's id
		#        data -> the new task's data
		def update(id, data={})
			if @tasks.update(id, data)
				if @tasks.save
					puts I18n.t('success.update', id: id).green
				else
					puts "#{I18n.t('display.error')} #6: #{@tasks.error_msg}".red
				end
			else
				puts "#{I18n.t('display.error')} #7: #{@tasks.error_msg}".red
			end
		end
	
		# Delete a tasks
		# @args: id -> the tasks's id
		def delete(id)
			if @tasks.delete(id)
				if @tasks.save
					puts I18n.t('success.delete', id: id).green
				else
					puts "#{I18n.t('display.error')} #8: #{@tasks.error_msg}".red
				end
			else
				puts "#{I18n.t('display.error')} #9: #{@tasks.error_msg}".red
			end
		end
	
		# List all tasks
		# @args: options -> filter for list
		def list(options={})
			table(border: false) do
				row(header: true, color: 'yellow') do
					column('ID', align: 'left', width: 5)
					column(I18n.t('display.group'), width: 20, align: 'left')
					column(I18n.t('display.name'), width: 40, align: 'left')
					column(I18n.t('display.progress'), width: 20, align: 'left')
					column(I18n.t('display.deadline'), width: 30, align: 'left')
				end
		
				@tasks.list(options).each do |t|
					task = t[1]
				
					row do
						column(task['id'])
						column(task['group'])
						column(task['name'])
						column("#{task['progress']}%", color: progress_color(task['progress']))
						column(task['deadline'], color: deadline_color(task['deadline']))
					end
				end
			end
		end
	
		private
		def progress_color(progress)
			case progress.to_i
			when 100
				return 'green'
			when 1..99
				return 'magenta'
			else
				return 'white'
			end
		end
	
		private 
		def deadline_color(deadline)
			time     = Time.now
			deadline = deadline.to_s
		
			if deadline.empty?
				return 'white'
			elsif Time.parse(deadline) < time
				return 'red'
			elsif Time.parse(deadline).to_i - time.to_i <= @config.deadline_limit
				return 'magenta'
			else
				return 'white'
			end
		end

	end
end
