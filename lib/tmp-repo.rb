# encoding: UTF-8

require 'tmpdir'
require 'pathname'
require 'fileutils'
require 'securerandom'

class TmpRepo
  DEFAULT_GIT_EXECUTABLE = 'git'

  class GitError < StandardError; end

  attr_reader :working_dir

  def self.random_dir
    File.join(Dir.tmpdir, SecureRandom.hex(16))
  end

  def initialize(dir = nil)
    @working_dir = Pathname(
      dir || self.class.random_dir
    )

    FileUtils.mkdir_p(working_dir)
    git('init')
  end

  def unlink
    FileUtils.rm_rf(working_dir.to_s)
    nil
  end

  def create_file(new_file)
    new_path = working_dir.join(new_file).to_s
    handle = File.open(new_path, 'w+')

    if block_given?
      yield handle
      handle.close
    else
      handle
    end
  end

  def add_all
    git('add -A')
  end

  def commit(message)
    git("commit -m '#{message.gsub("'", "\\\\'")}'")
  end

  def checkout(ref)
    git("checkout #{ref}")
  end

  def create_branch(branch_name)
    git("checkout -b #{branch_name}")
  end

  def current_branch
    git('rev-parse --abbrev-ref HEAD').strip
  end

  def status
    parse_status(git('status'))
  end

  def git(command)
    in_repo do
      output = `#{git_executable} #{command} 2>&1`

      if $?.exitstatus != 0
        raise GitError, output
      end

      output
    end
  end

  def in_repo
    Dir.chdir(working_dir.to_s) do
      yield
    end
  end

  private

  def git_executable
    DEFAULT_GIT_EXECUTABLE
  end

  def parse_status(status_text)
    lines = status_text.split("\n")
    status_hash = create_status_hash
    statuses = possible_statuses_from(status_hash)

    lines.each do |line|
      index = -1

      status = statuses.find do |status|
        index = line =~ /#{Regexp.escape(status)}: /
      end

      if status
        status = status_to_hash_key(status)
        status_hash[status] << line[(index + status.size + 2)..-1].strip
      end
    end

    status_hash
  end

  def status_to_hash_key(status)
    status.gsub(' ', '_').to_sym
  end

  def possible_statuses_from(status_hash)
    status_hash.keys.map do |status|
      status.to_s.gsub('_', ' ').downcase
    end
  end

  def create_status_hash
    { modified: [], deleted: [], new_file: [] }
  end
end
