require "test_helper"
require 'minitest/mock'

class WebsiteTest < ActionDispatch::IntegrationTest
  include OmiseMock
  test "should get index" do
    get "/"

    assert_response :success
  end

  test "that someone can't donate to no charity" do
    stub_token_retrieve do
      post(donate_path, params: {
             amount: "100", omise_token: "tokn_X", charity: ""
           })
    end

    assert_template :index
    assert_equal "Charity Please select one", flash.now[:alert]
  end

  test "that someone can't donate 0 to a charity" do
    charity = charities(:children)
    stub_token_retrieve do
      post(donate_path, params: {
             amount: "0", omise_token: "tokn_X", charity: charity.id
           })
    end

    assert_template :index
    assert_equal "Amount must be greater than or equal to 20 THB", flash.now[:alert]
  end

  test "that someone can't donate less than 20 to a charity" do
    charity = charities(:children)
    stub_token_retrieve do
      post(donate_path, params: {
             amount: "19", omise_token: "tokn_X", charity: charity.id
           })
    end

    assert_template :index
    assert_equal "Amount must be greater than or equal to 20 THB", flash.now[:alert]
  end

  test "that someone can't donate without a token" do
    charity = charities(:children)
    stub_token_retrieve do
      post(donate_path, params: {
             amount: "100", charity: charity.id
           })
    end

    assert_template :index
    assert_equal "Omise token can't be blank", flash.now[:alert]
  end

  test "that someone can donate to a charity" do
    charity = charities(:children)
    initial_total = charity.total
    expected_total = initial_total + (100 * 100)

    stub_create_charge do post(donate_path, params: {
           amount: "100", omise_token: "tokn_X", charity: charity.id
         })
    end
    follow_redirect!

    assert_template :index
    assert_equal t("website.donate.success"), flash[:notice]
    assert_equal expected_total, charity.reload.total
  end

  test "that if the charge fail from omise side it shows an error" do
    charity = charities(:children)

    # 999 is used to set paid as false
    stub_create_charge(error: true) do
      stub_token_retrieve do
        post(donate_path, params: {
               amount: "999", omise_token: "tokn_X", charity: charity.id
             })
      end
    end

    assert_template :index
    assert_equal "token tokn_X was not found (not_found)", flash.now[:alert]
  end

  test "that we can donate to a charity at random" do
    charities = Charity.all
    initial_total = charities.to_a.sum(&:total)
    expected_total = initial_total + (100 * 100)

    stub_create_charge do
      post(donate_path, params: {
             amount: "100", omise_token: "tokn_X", charity: "random"
           })
    end
    follow_redirect!

    assert_template :index
    assert_equal expected_total, charities.to_a.map(&:reload).sum(&:total)
    assert_equal t("website.donate.success"), flash[:notice]
  end
end
