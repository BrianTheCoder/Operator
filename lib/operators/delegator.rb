module Operators
  module Delegator #:nodoc:
    def root(path); Operators::Main.app.root(path) end
    
    def dir(name, opts = {}, &block); Operators::Main.app.dir(name, opts, &block) end
    
    def file(name, opts = {}, &block); Operators::Main.app.file(name, opts, &block) end
    
    def use_infile_templates!
      Operators::Main.app.use_infile_templates!
    end
    
    def gem(name, opts = {}, &block); Operators::Main.app.gem(name, opts, &block) end
    
    def commit(msg, opts = {}); Operators::Main.app.commit(msg, opts) end    
  end
end