require 'rubygems'
require 'simple-rss'
require 'open-uri'
require 'cgi'
require 'set'
require 'yaml'
require 'pry'

class Item
  attr_reader :name, :urls, :results

  def initialize(name:, urls:)
    @name = name.to_s
    @urls = Array(urls)
    @seen = Set.new
    @results = []
    load_seen_file
    search
    update_seen_file
  end

  private

  def load_seen_file
    seen_filepath = File.dirname(__FILE__) + "/../config/.seen.txt"
    if File.exists?(seen_filepath)
      file = File.open(seen_filepath, 'r')
      @seen = Marshal.load(file)
      file.close
    end
  end

  def update_seen_file
    seen_filepath = File.dirname(__FILE__) + "/../config/.seen.txt"
    file = File.open(seen_filepath, 'w')
    file << Marshal.dump(@seen)
    file.close
  end

  def search
    urls.each do |url|
      rss = open(url).read()
      rss.encode!('utf-8', 'binary', :invalid => :replace, :undef => :replace)
      feed = SimpleRSS.parse(rss)
      @results += Array(process_feed(feed))
    end
  end

  def process_feed(feed)
    feed.items.each_with_object([]) do |item, memo|
      post_id = item.link.match(/\d+/).to_s
      unless @seen.include? post_id
        @seen << post_id.to_s
        title = CGI.unescapeHTML(item.title).capitalize!
        link = item.link
        memo << { title: title, link: link }
      end
    end
  end
end
