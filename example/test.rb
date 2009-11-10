require 'pathname'

$root = Pathname(__FILE__).dirname.expand_path

require File.join($root, '..', 'lib', 'app')