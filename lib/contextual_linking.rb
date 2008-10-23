require 'page_context' # make sure we have the previous definition first

class PageContext < Radius::Context
  alias_method :old_init, :initialize

  def initialize(page)
    old_init page
    define_tag "contextual_links" do |tag|        
      string = ''    
      pages = get_pages(page, tag)
      if !pages.nil?
        string << '<ul>'
        pages.each do |page|
          string  << "<li><a href=\"#{page.url}\">#{page.title}</a></li>"
        end
        string << '</ul>'
      end
      string
    end
  end
  
  def get_pages(page, tag)
    results = nil
    keywords = page.keywords.split(' ')
    additional_keywords = tag.attr['keywords'] || "" 
    number_of_links = tag.attr['limit'] || "3" 
    all_keywords = keywords << additional_keywords
    if all_keywords.length != 0
      conditions = " ( id != #{page.id} ) AND ("
      counter = 0
      all_keywords.each do |keyword|
        counter += 1
        if !keyword.blank?
          conditions << ' OR ' if counter != 1
          conditions << " UPPER(keywords) LIKE UPPER('%#{keyword}%') "
        end
      end
      conditions << ')'
      results = Page.find(:all, :conditions => conditions, :limit => number_of_links)
    end
    results
  end
  
end