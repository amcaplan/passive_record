require 'spec_helper'

describe User do
  let(:db) { DB.instance }

  def db_call(str)
    expect(db).to receive(:call).with(str).and_call_original
  end

  it "gets all" do
    db_call("SELECT * FROM users")
    User.all
  end

  it "gets one" do
    db_call("SELECT * FROM users WHERE id = 1")
    User.find(1)
  end

  it "gets the first" do
    db_call("SELECT * FROM users ORDER BY id DESC LIMIT 1")
    User.first
  end

  it "updates the account" do
    account = Account.first
    user = User.new(id: 5)
    db_call("UPDATE users SET account_id = #{account.id} WHERE id = #{user.id}")
    user.account = account
    expect(user.account).to eq(account)
  end

  describe "validations" do
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
