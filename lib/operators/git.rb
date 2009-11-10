require 'git'

module Operators
  class Git
    attr :_dir, :_git
    def initialize(dir = nil)
      self._git = Git.init(dir) unless dir.blank?
    end
    
    def self.open(dir)
      repo = self.new
      repo._git = Git.open(dir)
    end
    
    def commit(msg, opts = {})
      if opts[:all]
        @_git.commit_all(msg)
      else
        @_git.add(opts.has_key?(:files) ? opts[:files] : @_files)
        @_git.commit(msg)
      end
    end
  end
end