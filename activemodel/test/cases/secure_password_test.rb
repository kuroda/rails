require 'cases/helper'
require 'models/user'
require 'models/visitor'
require 'models/administrator'

class SecurePasswordTest < ActiveModel::TestCase

  setup do
    @user = User.new
  end

  test "blank password" do
    @user.password = ''
    assert !@user.valid?, 'user should be invalid'
  end

  test "nil password may be allowed" do
    @user.password = nil
    assert @user.valid?
  end

  test "password may not be present" do
    assert @user.valid?
  end

  test "password must match confirmation" do
    @user.password = "thiswillberight"
    @user.password_confirmation = "wrong"

    assert !@user.valid?

    @user.password_confirmation = "thiswillberight"

    assert @user.valid?
  end

  test "authenticate" do
    @user.password = "secret"

    assert !@user.authenticate("wrong")
    assert @user.authenticate("secret")
  end

  test "never authenticate if password_digest is nil" do
    assert !@user.authenticate("")
    assert !@user.authenticate(nil)
  end

  test "visitor#password_digest should be protected against mass assignment" do
    assert Visitor.active_authorizers[:default].kind_of?(ActiveModel::MassAssignmentSecurity::BlackList)
    assert Visitor.active_authorizers[:default].include?(:password_digest)
  end

  test "Administrator's mass_assignment_authorizer should be WhiteList" do
    active_authorizer = Administrator.active_authorizers[:default]
    assert active_authorizer.kind_of?(ActiveModel::MassAssignmentSecurity::WhiteList)
    assert !active_authorizer.include?(:password_digest)
    assert active_authorizer.include?(:name)
  end
end
