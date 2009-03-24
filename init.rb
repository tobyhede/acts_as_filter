$:.unshift "#{File.dirname(__FILE__)}/lib"
require "acts_as_filter"
ActiveRecord::Base.class_eval { include ActsAsFilter }