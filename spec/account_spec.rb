require 'spec_helper'
Dir.glob('./**/*.rb').each do |file|
  require file unless file.start_with?('./spec')
end

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
    db_call("SELECT * FROM users WHERE id = #{account.id}")
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

  context "within a user" do
    it "updates the account" do
      account = Account.first
      user = User.new(id: 5)
      db_call("UPDATE users SET account_id = #{account.id} WHERE id = #{user.id}")
      user.account = account
    end

    context "given a valid user" do
      let(:user) { User.new(id: 1, username: "Ariel") }

      it "accepts as valid" do
        expect(user).to be_valid
      end
    end

    context "given an invalid user" do
      context "no username" do
        let(:user) { User.new(id: 1, username: nil) }

        it "marks as invalid" do
          expect(user).not_to be_valid
        end
      end

      context "empty string username" do
        let(:user) { User.new(id: 1, username: "   ") }

        it "marks as invalid" do
          expect(user).not_to be_valid
        end
      end
    end
  end
end
