require 'open-uri'
require 'time'
require 'rexml/document'

class Delicious
  include REXML

  attr_accessor :url, :items, :link, :title
    
  # This object holds given information of an item
  class DeliciousItem < Struct.new(:link, :title)  
    def to_s; title end          
  end
    
  # Pass the url to the RSS feed you would like to keep tabs on
  # by default this will request the rss from the server right away and 
  # fill the items array
  def initialize(url, refresh = true)
	self.items  = []
	self.url    = url
	self.refresh if refresh
  end
  
  # This method lets you refresh the items in the items array
  # useful if you keep the object cached in memory and 
  def refresh
    open(@url) do |http|
      parse(http.read)
    end
  end
  
private

  def parse(body)
  
    xml = Document.new(body)
  
    self.items        = []    
    self.link         = XPath.match(xml, "//channel/link/text()").to_s
    self.title        = XPath.match(xml, "//channel/title/text()").to_s
          
    XPath.each(xml, "//item/") do |elem| 
    
      item = DeliciousItem.new
      item.title       = XPath.match(elem, "title/text()").to_s                  
      item.link        = XPath.match(elem, "link/text()").to_s
      
      items << item
    end
  end  
end
