require 'spec_helper'

describe Account do
  let(:db) { DB.instance }

  def db_call(str)
    expect(db).to receive(:call).with(str).and_call_original
  end

  it "gets all" do
    db_call("SELECT * FROM accounts")
    Account.all
  end

  it "gets one" do
    db_call("SELECT * FROM accounts WHERE id = 1")
    Account.find(1)
  end

  it "gets the first" do
    db_call("SELECT * FROM accounts ORDER BY id DESC LIMIT 1")
    Account.first
  end

  it "gets associated users" do
    account = Account.first
    db_call("SELECT * FROM users WHERE account_id = #{account.id}")
    users = account.users
    expect(users.first).to be_a(User)
  end

  it "adds a user" do
    account = Account.first
    users = account.users
    new_user = User.new(id: 4)
    db_call("UPDATE users SET account_id = #{account.id} WHERE id = #{new_user.id}")
    users << new_user
  end

  it "removes all users" do
    account = Account.first
    users = account.users
    db_call("DELETE FROM users WHERE account_id = #{account.id}")
    users.delete_all
    expect(account.users).to be_empty
  end
end
