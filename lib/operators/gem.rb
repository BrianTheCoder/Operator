module Operators
  class Gem
    attr_accessor :name, :version, :options
    
    def initialize(name, version, opts = {})
      self.name = name
      if version.is_a? String
        self.version = version
      elsif version.is_a? Hash
        opts = version
      end
      self.options = opts
    end
  end
end