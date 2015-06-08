require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "user@example.com")
  end

  test "is valid?" do
    assert @user.valid?
  end

  test "should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "email length less than 255" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "valid email addresses should be valid" do
    valid_add = ["user@example.com", "TESTER@test.CoM", "S_underscores_test.more@example.jp", "sir+nine@example.com"]
    valid_add.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "invalid email addresses should be invalid" do
    invalid_add = ["user@example,com", "TESTER_at_test.CoM", "user.name@example.", "S_underscores_test@example+example.com"]
    invalid_add.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    dup_user = @user.dup
    dup_user.email = @user.email.upcase
    @user.save
    assert_not dup_user.valid?
  end

  test "email addresses should be downcased before saving" do
    @user.email = "USeR@exaMpLE.cOM"
    @user.save
    saved_email = User.find_by(email: "user@example.com")["email"]
    assert saved_email == @user.email.downcase
  end
end