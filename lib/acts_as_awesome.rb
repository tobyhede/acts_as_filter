require "active_record"

module ActsAsAwesome #:nodoc:

  def self.included(base)
    base.extend(ClassMethods)
  end
  
    
  module ClassMethods

      def acts_as_awesome(opts={})
          options = options_for_scheduled(opts)
          extend ActsAsAwesome::SingletonMethods
          include ActsAsAwesome::InstanceMethods
          
          class_eval do                       
          end
      end
            
      def options_for_scheduled(opts={})
        {}.merge(opts)
      end
  end
  
  
  module SingletonMethods
    
    def find_by_filter(opts)
      
      filter_scopes = []
      opts.each do |name, value|    
        if scopes.has_key?(name)
          filter_scopes << [name, value]          
        else
          filter_scopes << [:scoped, {:conditions => ["#{name} = ?", value]}]
        end        
      end

      filter_scopes.inject(eval(self.to_s)) {|model,scope| model.scopes[scope[0]].call(model, scope[1]) }    
    end
    
  end


  module InstanceMethods #:nodoc:
  end
  

end

