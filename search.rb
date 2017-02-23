require './lib/item.rb'
require './lib/mailer.rb'
require 'yaml'
require 'pry'

file = File.open(File.dirname(__FILE__) + "/config/wanted.yml", "r")
search_items = YAML.load(file)

items = search_items.map do |search_item|
  Item.new(name: search_item[:name], urls: search_item[:urls])
end

mailer = Mailer.new(items: items)
mailer.send
