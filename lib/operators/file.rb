require 'tilt'
require 'httparty'

module Operators
  class File
    attr_accessor :dir, :filename, :_content, :_remote, :_template, :_variables
    
    def initialize(name, opts = {}, &block)
      path = Pathname(name)
      self.dir      = path.dirname
      self.filename = path.basename
      self._content = ''
      if opts.is_a? String
        self._content = opts
      else
        self._remote    = opts[:source] if opts.has_key?(:source)
        self._template  = opts[:template] if opts.has_key?(:template)
        self._variables = opts[:variables] if opts.has_key?(:variables)
      end
      instance_eval(&block) if block_given?
    end
    
    def content; @_content ||= [] end
    
    def render(root)
      path = ::File.join(root, filename)
      file = ::File.new(path,'w')
      puts "File   [#{filename}]:\t#{path}"
      content = if @_template
        Tilt.new(@_template).render(@_variables)
      elsif @_remote
        HTTParty.get(@_remote).body
      else
        @_content
      end
      file.puts content
      file.close
    end
  end
end