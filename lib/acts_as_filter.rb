require "active_record"

module ActsAsFilter #:nodoc:

  def self.included(base)
    base.extend(ClassMethods)
  end
  
    
  module ClassMethods

      def acts_as_filter(opts={})
          options = options_for_filter(opts)
          extend ActsAsFilter::SingletonMethods
          include ActsAsFilter::InstanceMethods
          
          class_eval do                       
          end
      end
            
      def options_for_filter(opts={})
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
            
      order = opts[:order] || "id ASC"    
      page = opts[:page] || 1
      per_page = opts[:per_page] || 10
      
      filter_scopes.inject(eval(self.to_s)) {|model,scope| model.scopes[scope[0]].call(model, scope[1]) }.paginate(:all, :order => order, :page => page, :per_page => per_page)       
      
    end
    
  end


  module InstanceMethods #:nodoc:
  end
  

end

