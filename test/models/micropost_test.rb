require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:earthsong)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    @user_two = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be max 240 characters long" do
    @micropost.content = "a" * 241
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test "associated microposts should be destroyed" do
    @user_two.save
    @user_two.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user_two.destroy
    end
  end

end
