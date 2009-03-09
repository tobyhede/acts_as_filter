require 'test/unit'
require 'rubygems'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")


class Document < ActiveRecord::Base
    acts_as_awesome
    belongs_to :author
    
    named_scope :test, :conditions => ["id = 1"]

    named_scope :author_name, 
                lambda { |*args| {
                  :include => "author",
                  :conditions => ["authors.name = ?", args.first]
                }}
                                
end

  
class Author < ActiveRecord::Base
  has_many :documents
end
  
module AwesomeHelper

  def create_document
    create_documents(1)
  end
  
  def create_documents(count  = 10)
    count.times do |i|
      doc = Document.new(:name=>"document_#{i}", :uuid=>"ABCDEF.#{i}", :published => Time.now)
      doc.save!    
    end
  end
  
  
end

    
class ActsAsAwesomeTest < Test::Unit::TestCase
    include AwesomeHelper
    
    def setup  
      
      ActiveRecord::Schema.define do
        
        create_table :documents, :force => true do |t|
          t.integer   :author_id
          t.string    :name
          t.string    :uuid
          t.datetime  :published                    
        end
                
        create_table :authors, :force => true do |t|
          t.string    :name
        end
                        
      end
    end
  
    def teardown
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    end


    def test_sanity
      doc = Document.new(:name=>"document_one", :uuid=>"ABCDEF123", :published => Time.now)
      doc.save!         
      assert_equal("document_one", doc.name)
    end


    def test_filter
      create_documents
      
      options = {:test => ""}      
      documents = Document.find_by_filter(options)

      assert(documents)    
      assert(documents.size == 1)    
      
      document = documents[0]      
      assert_equal(1, document.id)
    end
    
        
    def test_anaonymous_filter
      create_documents
      
      options = {:name => "document_1"}      
      documents = Document.find_by_filter(options)
    
      assert(documents)    
      assert(documents.size == 1)    
      
      document = documents[0]      
      assert_equal("document_1", document.name)
    end
    
    
    def test_associated_filter
      create_documents
      
      author = Author.new(:name=>"toby")
      author.save!    
      
      document = Document.find_by_name("document_1")
      document.author = author
      document.save!
            
      options = {:author_name => "toby"}      
      documents = Document.find_by_filter(options)
    
      assert(documents)    
      assert(documents.size == 1)    
      
      document = documents[0]      
      assert_equal("document_1", document.name)
    end
    
end