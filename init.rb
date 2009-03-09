$:.unshift "#{File.dirname(__FILE__)}/lib"
require "acts_as_awesome"
ActiveRecord::Base.class_eval { include ActsAsAwesome }