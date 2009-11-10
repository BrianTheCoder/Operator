require 'operators/builder'
require 'operators/delegator'

module Operators
  class Main
    caller(1)
    # we assume that the first file that requires 'sinatra' is the
    # app_file. all other path related options are calculated based
    # on this path by default.
    class << self
      def root(path = nil)
        if path
          @_root = path
        else
          return @_root unless @_root.blank?
          @_root = (caller_files.last || $0)
        end
      end
    
      CALLERS_TO_IGNORE = [
        /\/app(\/(builder|main))?\.rb$/, # all app-builder code
        /lib\/tilt.*\.rb$/,    # all tilt code
        /\(.*\)/,              # generated code
        /custom_require\.rb$/, # rubygems require hacks
        /active_support/,      # active_support require hacks
      ]

      # add rubinius (and hopefully other VM impls) ignore patterns ...
      CALLERS_TO_IGNORE.concat(RUBY_IGNORE_CALLERS) if defined?(RUBY_IGNORE_CALLERS)

      # Like Kernel#caller but excluding certain magic entries and without
      # line / method information; the resulting array contains filenames only.
      def caller_files; caller_locations.map { |file,line| file } end

      def caller_locations
        caller(1).
          map    { |line| line.split(/:(?=\d|in )/)[0,2] }.
          reject { |file,line| CALLERS_TO_IGNORE.any? { |pattern| file =~ pattern } }
      end
    
      def app
        @_app ||= Operators::Builder.new(root)
      end
    end  
    
    at_exit do
      raise $! if $!
      p 'build'
      app.build
    end
  end
end

include Operators::Delegator    