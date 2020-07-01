require './passive_record'

class Account < PassiveRecord
  has_many :users
end
