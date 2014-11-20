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

class Cli

	# Constructor
	def initialize
		@tasks = Tasks.new

		if not @tasks.load
			puts "#{I18n.t('display.error')} #1: #{todo.error_msg}"
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
				puts "#{I18n.t('display.error')} #2: #{todo.error_msg}".red
			end
		else
			puts "#{I18n.t('display.error')} #3: #{todo.error_msg}".red
		end
	end

	# Show a task
	# @args: id -> the tasks's id
	def show(id)
		task = @tasks.show(id)
		if task.empty?
			puts "#{I18n.t('diplay.error')} #4: #{todo.error_msg}".red
		else
			print "##{task['id']} - ".yellow
			print "#{task['name']} - "
	
			print "#{I18n.t('display.progress')}: ".yellow
			progress = task['progress'].to_i

			case progress
			when 100
				puts "#{progress}%".green
			when 1..99
				puts "#{progress}%".magenta
			else
				puts "#{progress}%"
			end

			puts '-' * 50

			print "#{I18n.t('display.deadline')}: ".yellow
			puts task['deadline']
			print "#{I18n.t('display.comment')}: ".yellow
			puts task['comment']

			puts '-' * 50

			print "#{I18n.t('display.date_create')}: ".yellow
			puts task['date_create']
			print "#{I18n.t('display.date_update')}: ".yellow
			puts task['date_update']

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
				puts "#{I18n.t('display.error')} #6: #{todo.error_msg}".red
			end
		else
			puts "#{I18n.t('display.error')} #7: #{todo.error_msg}".red
		end
	end

	# Delete a tasks
	# @args: id -> the tasks's id
	def delete(id)
		if @tasks.delete(id)
			if @tasks.save
				puts I18n.t('success.delete', id: id).green
			else
				puts "#{I18n.t('display.error')} #8: #{todo.error_msg}".red
			end
		else
			puts "#{I18n.t('display.error')} #9: #{todo.error_msg}".red
		end
	end

	# List all tasks
	def list
		table(border: false) do
			row(header: true, color: 'yellow') do
				column('ID', align: 'left')
				column(I18n.t('display.name'), width: 30, align: 'left')
				column(I18n.t('display.progress'), width: 20, align: 'left')
				column(I18n.t('display.deadline'), width: 30, align: 'left')
			end
	
			@tasks.list.each do |t|
				task = t[1]
			
				row do
					column(task['id'])
					column(task['name'])
	
					# Set print progress
					progress = task['progress'].to_i
					case progress
					when 100
						column("#{progress}%", color: 'green')
					when 1..99
						column("#{progress}%", color: 'magenta')
					else
						column("#{progress}%")
					end
	
					# Set print Deadline
					deadline = task['deadline'].to_s
					time     = Time.now
	
					if deadline.to_s.empty?
						column(I18n.t('display.nothing'))
					elsif Time.parse(deadline) < time
						column(task['deadline'], color: 'red')
					elsif Time.parse(deadline).to_i - time.to_i <= 3 * 24 * 60 * 60 # 3 days
						column(task['deadline'], color: 'magenta')
					else
						column(task['deadline'])
					end
				end
			end
		end

	end
end
