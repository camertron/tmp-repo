tmp-repo
========

Creates and manages a git repository in the operating system's temporary directory. Useful for running git operations in tests.

## Installation

`gem install tmp-repo`

## Usage

```ruby
require 'tmp-repo'
```

### Basics

Creating a new `TmpRepo` will automatically choose a folder in your system's temp directory and initialize a git repository in it:

```ruby
repo = TmpRepo.new
repo.working_dir # => #<Pathname:/var/folders/3x/n10r69b16bq_rlcqr3fy0rwc0000gn/T/b068487773901ffe23e66a8259711fa1>
```

Once created, you can ask your `TmpRepo` questions and perform operations. Don't forget to clean up after yourself when you're finished:

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

## Requirements

No external requirements.

## Running Tests

`bundle exec rake` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
