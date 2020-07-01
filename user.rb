require './passive_record'

class User < PassiveRecord
  has_one :account

  validates :username, presence: true
end
