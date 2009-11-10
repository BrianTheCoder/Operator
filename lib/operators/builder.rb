require 'command'
require 'directory'
require 'file'
require 'gem'
require 'git'

module Operators
  class Builder
    attr_accessor :_root, :_structure, :_git, :_files, :_gems, :_templates, :_caller
  
    def initialize(dir, opts = {}, &block)
      path = Pathname(dir)
      self._root = path.dirname.expand_path
      self._caller = path.basename
      self._structure = []
      self._gems = []
      instance_eval(&block) if block_given?
    end
    
    def root(path)
      self._root = Pathname(path).expand_path
    end
        
    def use_infile_templates!
      @_templates ||= {}
      file ||= @_caller
      
      begin
        app, data =
          ::IO.read(file).gsub("\r\n", "\n").split(/^__END__$/, 2)
      rescue Errno::ENOENT
        app, data = nil
      end
      
      if data
        lines = app.count("\n") + 1
        template = nil
        data.each_line do |line|
          lines += 1
          if line =~ /^@@\s*(.*)/
            template = ''
            @_templates[$1.to_sym] = template
          elsif template
            template << line
          end
        end
      end
    end
    
    def gem(name, version, opts = {})
      self._gems << Operators::Gem.new(name, version, opts)
    end
  
    def dir(name, opts = {}, &block)
      self._structure << Operators::Directory.new(name, opts, &block)
    end
    
    def file(name, opts = {}, &block)
      opts = @_templates[opts] if opts.is_a? Symbol
      self._structure << Operators::File.new(name, opts, &block)
    end
    
    def build
      @_structure.each do |item| 
        if item.is_a?(Operators::File)
          item.render(@_root)
        elsif item.is_a?(Operators::Directory)
          item.build(@_root)
        end
      end
      render_gems
    end
    
    private
    
    def render_gems
      gemfile = Operators::File.new("Gemfile")
      gemfile.content << "source \"http://gems.rubyforge.org\"\n"
      gemfile.content << "source \"http://gemcutter.org\"\n"
      gemfile.content << "source \"http://gems.github.com\"\n\n"
      gemfile.content << "bundle_path \"gems\"\n\n"
      @_gems.each do |gem|
        gemfile.content << "gem \"#{gem.name}\""
        gemfile.content << ",\"#{gem.version}\"" unless gem.version.blank?
        gemfile.content << ",\"#{gem.options}\"" unless gem.options.blank?
        gemfile.content << "\n"
      end
      gemfile.render(@_root)
      # Operator::Command.run('gem bundle')
    end
  end
end