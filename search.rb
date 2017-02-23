require './lib/item.rb'
require './lib/mailer.rb'
require 'yaml'
require 'pry'

file = File.open(File.dirname(__FILE__) + "/config/wanted.yml", "r")
search_items = YAML.load(file)

search_items.each do |search_item|
  items = search_item[:items].map do |item|
    Item.new(name: item[:name], urls: item[:urls])
  end

  mailer = Mailer.new(items: items, recipients: search_item[:recipients])
  mailer.send
end

