require 'test_helper'
require 'minitest/mock'

 class CreateChargeTest < ActiveSupport::TestCase
  include OmiseMock
  subject = CreateCharge

  def setup
    @charity = charities(:children)

    @charge_params = {
      omise_token: 'tk9',
      charity: @charity,
      amount: '50'
    }
  end

  test 'that charge is created fine with valid params' do
    charge = subject.new(@charge_params)

    stub_create_charge do
      charge.call
    end

    assert charge.valid?
    assert charge.errors.empty?
    assert_equal @charity.reload.total, charge.amount
  end

  test 'that charge returns an error when Charity is not present' do
    @charge_params[:charity] = nil
    create_charge = subject.new(@charge_params).call

    assert_equal "Charity Please select one", create_charge.errors
  end

  test 'that charge returns an error when omise_token is blank' do
    @charge_params[:omise_token] = ''
    create_charge = subject.new(@charge_params).call

    assert_equal "Omise token can't be blank", create_charge.errors
  end

  test "that charge returns an error when amount is is less than 20 THB" do
    @charge_params[:amount] = '17'
    create_charge = subject.new(@charge_params).call

    assert_equal "Amount must be greater than or equal to 20 THB", create_charge.errors
  end
end
