module Operators
  class Directory
    attr_accessor :dirname, :basename, :_structure
    
    def initialize(name, opts = {}, &block)
      path = Pathname(name)
      self._structure = []
      self.dirname  = path.dirname
      self.basename = path.basename
      instance_eval(&block) if block_given?
    end
    
    def dir(name, opts = {}, &block)
      self._structure << Operators::Directory.new("#{basename}/#{name}", opts, &block)
    end
    
    def file(name, opts = {}, &block)
      self._structure << Operators::File.new("#{basename}/#{name}", opts, &block)
    end
    
    def build(root)
      path = ::File.join(root, basename)
      puts "Making [#{basename}]:\t\t#{path}"
      FileUtils.mkdir_p path, :mode => 0o755
      @_structure.each do |item| 
        if item.is_a?(Operators::File)
          item.render(path)
        elsif item.is_a?(Operators::Directory)
          item.build(path)
        end
      end
    end
  end
end