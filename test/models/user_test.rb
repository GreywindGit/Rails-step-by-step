require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "Minstrel", email: "minstrel@gmail.com", 
                     password: "python", password_confirmation: "python")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 246 + "@gmail.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should not be valid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses shoul be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = "   "
    assert_not @user.valid?
  end

  test "password shoul have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "should follow and unfollow a user" do
    earthsong = users(:earthsong)
    judy  = users(:judy)
    assert_not earthsong.following?(judy)
    earthsong.follow(judy)
    assert earthsong.following?(judy)
    assert judy.followers.include?(earthsong)
    earthsong.unfollow(judy)
    assert_not earthsong.following?(judy)
  end

  test "feed should have the right posts" do
    earthsong = users(:earthsong)
    judy = users(:judy)
    sheridan = users(:sheridan)
    # Post from followed user
    sheridan.microposts.each do |post_following|
      assert earthsong.feed.include?(post_following)
    end
    # Posts from self
    earthsong.microposts.each do |post_self|
      assert earthsong.feed.include?(post_self)
    end
    # Posts from unfollowed user
    judy.microposts.each do |post_unfollowed|
      assert_not earthsong.feed.include?(post_unfollowed)
    end
  end

end
