# Todo-cli

## Introduction

Todo-cli is a little software in cli for manage tasks.
You can create a simple tasks with:
* a name
* a comment
* a deadline
* a progress

## Install

* install ruby on your computer
* make configure
* make install

## Use

For all commands:
* todo-cli -h

Example:
* todo-cli -a -n 'Take a shower' # Add a new task with the name 'Take a shower'
* todo-cli -a -n 'Test' -c 'This is a test' # Add a new tasks with a name and a comment
* todo-cli # List all task
* todo-cli -u 1 -d '2015-02-23 17:37:00' # Update the task number #1 with a new deadline 
