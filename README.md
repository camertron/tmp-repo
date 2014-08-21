tmp-repo
========

[![Build Status](https://travis-ci.org/camertron/tmp-repo.svg?branch=master)](http://travis-ci.org/camertron/tmp-repo)

Creates and manages git repositories in the operating system's temporary directory. It does this by providing a thin wrapper around the git binary that's pointed at a randomly generated temporary folder.

## Installation

`gem install tmp-repo`

## Usage

```ruby
require 'tmp-repo'
```

### Basics

Creating a new `TmpRepo` will automatically create a randomly named folder in your system's temp directory and initialize a git repository in it:

```ruby
repo = TmpRepo.new
repo.working_dir # => #<Pathname:/var/folders/3x/n10r69b16bq_rlcqr3fy0rwc0000gn/T/b068487773901ffe23e66a8259711fa1>
```

Once created, you can ask your `TmpRepo` questions and perform operations on it. Don't forget to clean up after yourself when you're finished:

```ruby
repo.unlink
```

### Creating Files

```ruby
repo.create_file('foo.txt') do |f|
  f.write("I'm a new file!")
end
```

OR

```ruby
file = repo.create_file('foo.txt')
file.write("I'm a new file!")
file.close
```

### Branching

To create a new branch:

```ruby
repo.create_branch('my_new_branch')
```

To check out a branch:

```ruby
repo.checkout('my_other_branch')
```

To get the current branch:

```ruby
repo.current_branch  # => 'master'
```

### Staging and Committing

To add all files to the git stage:

```ruby
repo.add_all
```

To commit staged files:

```ruby
repo.commit('Commit message')
```

### Repo Status

`TmpRepo` instances provide a convenient way to retrieve the status of the repository via the `status` method. `status` return values are a simple hash of arrays:

```ruby
status = repo.status
status[:new_file]  # => ['file1.txt', 'file2.txt']
status[:deleted]   # => ['file3.txt']
status[:modified]  # => ['file4.txt']
```

### Custom Commands

This library only provides wrapper methods around the most common git commands. To run additional git commands, use the `git` method:

```ruby
repo.git('rebase master')
```

In addition, the lower-level `in_repo` method wraps the given block in a `Dir.chdir`, meaning the block is executed in the context of the repo's working directory:

```ruby
repo.in_repo do
  `ls`  # list files in the repo's working directory
end
```

## Requirements

No external requirements.

## Running Tests

`bundle exec rake` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
