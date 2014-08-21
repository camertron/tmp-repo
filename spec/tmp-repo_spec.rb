# encoding: UTF-8

require 'spec_helper'

describe TmpRepo do
  let(:repo) do
    TmpRepo.new
  end

  after(:each) do
    repo.unlink
  end

  def in_repo
    Dir.chdir(repo.working_dir.to_s) do
      yield
    end
  end

  describe '#initialize' do
    it 'should initialize the repository' do
      expect(repo.working_dir.join('.git')).to exist
    end
  end

  describe '#unlink' do
    it 'should delete the temp directory' do
      repo.unlink
      expect(repo.working_dir).to_not exist
    end
  end

  describe '#create_file' do
    it 'yields a file handle if given a block' do
      repo.create_file('foo.txt') do |f|
        expect(f).to be_a(IO)
        f.write('foobar')
      end

      contents = File.read(repo.working_dir.join('foo.txt').to_s)
      expect(contents).to eq('foobar')
    end

    it 'returns a file handle if not given a block' do
      handle = repo.create_file('foo.txt')
      expect(handle).to be_a(IO)
      handle.write('foobarbaz')
      handle.close

      contents = File.read(repo.working_dir.join('foo.txt').to_s)
      expect(contents).to eq('foobarbaz')
    end
  end

  describe '#add_all' do
    it 'stages all files' do
      repo.create_file('foo.txt') { |f| f.write('foobar') }
      repo.add_all

      in_repo do
        expect(`git status`).to match(/new file:[\s]+foo\.txt/)
      end
    end
  end

  describe '#commit' do
    it 'commits the stage' do
      repo.create_file('foo.txt') { |f| f.write('foobar') }
      repo.add_all
      repo.commit('Committing foobar')

      in_repo do
        expect(`git log`).to match(/Committing foobar/)
        expect(`git show --name-only HEAD`).to include('foo.txt')
      end
    end
  end

  context 'with a single commit' do
    before(:each) do
      repo.create_file('foo.txt') do |f|
        f.write('foobar')
      end

      repo.add_all
      repo.commit('Foobar committed')
    end

    describe '#checkout' do
      it 'checks out the given branch' do
        in_repo do
          `git checkout -b my_branch && git checkout master`
          expect(`git rev-parse --abbrev-ref HEAD`.strip).to eq('master')
        end

        repo.checkout('my_branch')

        in_repo do
          expect(`git rev-parse --abbrev-ref HEAD`.strip).to eq('my_branch')
        end
      end
    end

    describe '#create_branch' do
      it 'creates a new branch' do
        repo.create_branch('new_branch')

        in_repo do
          expect(`git branch`).to include('new_branch')
        end
      end
    end

    describe '#current_branch' do
      it 'returns the current branch name' do
        in_repo { `git checkout -b cool_branch` }
        expect(repo.current_branch).to eq('cool_branch')
      end
    end

    describe '#status' do
      it 'returns no results when there are no uncommitted changes' do
        repo.status.tap do |status|
          expect(status[:new_file]).to be_empty
          expect(status[:modified]).to be_empty
          expect(status[:deleted]).to be_empty
        end
      end

      it 'shows new files' do
        repo.create_file('hello.txt') do |f|
          f.write('blarg blegh')
        end

        repo.add_all

        repo.status.tap do |status|
          expect(status[:new_file]).to include('hello.txt')
        end
      end

      it 'shows modified files' do
        in_repo do
          File.open('foo.txt', 'w+') do |f|
            f.write("\nI'm a change!")
          end

          repo.add_all

          repo.status.tap do |status|
            expect(status[:modified]).to include('foo.txt')
          end
        end
      end

      it 'shows deleted files' do
        in_repo do
          File.unlink('foo.txt')
          repo.add_all

          repo.status.tap do |status|
            expect(status[:deleted]).to include('foo.txt')
          end
        end
      end
    end

    describe '#git' do
      it 'facilitates executing custom git commands and returning their output' do
        expect(repo.git('branch')).to include('master')
      end

      it 'raises an error if the command fails' do
        expect(lambda { repo.git('') }).to raise_error(TmpRepo::GitError)
      end
    end
  end
end
