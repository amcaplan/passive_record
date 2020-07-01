require 'singleton'

class DB
  include Singleton

  def call(str)
    "Calling database: #{str}".tap do |str|
      puts str if ENV['DEBUG']
    end
  end
end
