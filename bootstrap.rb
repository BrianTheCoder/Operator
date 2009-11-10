require 'rubygems'
require 'pathname'

require 'lib/operator'

root File.join(File.dirname(__FILE__),'..')

dir 'log'
dir 'models'
file 'app.rb', :app
file 'config.ru', "run App"
dir 'lib'
dir 'public' do
  dir 'images'
  dir 'stylesheets'
  dir 'javascripts' do
    file 'jquery.js', :source => 'http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js'
    file 'main.js'
  end
end
dir 'views'
gem 'sinatra', :require_as => 'sinatra/base'
gem 'sinatra_more'
gem 'paginator'
gem 'yajl-ruby', :require_as => 'yajl'
gem 'warden'
gem 'haml'
gem 'compass'
gem 'typhoeus'
gem 'stringex'
gem 'rack-contrib', :require_as => 'rack/contrib'
gem 'rack-flash', :require_as => 'rack/flash'
gem 'redis-namespace', :require_as => 'redis/namespace'
gem 'resque'
gem 'redis'
gem 'ruby-openid', :require_as => 'openid'
gem 'extlib'
gem 'mongo_mapper'
gem 'git'

__END__

@@ layout
!!! Strict
%html{ html_attrs("en_us") }
  %head
    %title Title
    %meta{ :content => "text/html; charset=utf-8", "http-equiv" => "content-type" }/
    =stylesheet_link_tag 'styles.css'
  %body
    =yield
    =javascript_include_tag 'jquery', 'main'

@@ app
class App < Sinatra::Default
  register SinatraMore::MarkupPlugin
  register SinatraMore::RenderPlugin
  
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views'
  end

    set :sass, Compass.sass_engine_options

  disable :run
  enable :static, :session, :methodoverride, :reload
  set :app_file, __FILE__

  error do
   e = request.env['sinatra.error']
   puts e.to_s
   puts e.backtrace.join('\n')
   'Application error'
  end
  
  get '/stylesheets/styles.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :styles
  end
end