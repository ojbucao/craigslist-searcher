require 'mail'
require 'yaml'
require 'io/console'

class Mailer
  file = File.open(File.dirname(__FILE__) + "/../config/mailer.yml", 'r')
  config = YAML.load(file)

  Options = {
    address: config['address'],
    port: config['port'],
    user_name: config['user_name'],
    password: -> { print 'email password: '; STDIN.getpass }.call,
    authentication: config['authentication'].to_s.to_sym,
    enable_starttls_auto: config['enable_starttls_auto'] }

  Recipients = config['recipients']

  Mail.defaults do
    delivery_method :smtp, Options
  end

  def initialize(items:)
    @recipients = Array(Recipients)
    @items = Array(items)
    @content ||= build_content
  end

  def send
    @recipients.each do |recipient|
      mail = Mail.new do
        to recipient
        from Options[:user_name]
        subject "Craigslist Search Results"

        html_part do
          content_type 'text/html; charset=UTF-8'
          body @content
        end
      end
      mail.deliver
    end
  end

  private

  def build_content
    content = ""
    @items.each do |item|
      content << "<h3>#{item.name}</h3>"
      content << '<ol>'
      item.results.each do |result|
        content << "<li><a href='#{result[:link]}'>#{result[:title]}</a></li>"
      end
      content << '</ol>'
      content << '<hr>'
    end
  end
end
