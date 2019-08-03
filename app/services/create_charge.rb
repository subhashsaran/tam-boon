class CreateCharge
  include ActiveModel::Model
  MIN_AMOUNT_CENTS = 2000.freeze

  attr_accessor :omise_token
  attr_reader :charity, :amount

  validates :omise_token, presence: true
  validates :charity, presence: true
  validate :minimum_amount_in_cents

  def initialize(params)
    assign_attributes(params)
  end

  def call
    if valid?
      begin
        charge = Omise::Charge.create(charge_params)
        if charge.paid
          charity.credit_amount(charge.amount)
          build_result(:success)
        else
          build_result(:failure, charge.failure_message)
        end
      rescue Omise::Error => e
        build_result(:failure, e.message)
      end
    else
      build_result(:failure, errors.full_messages.to_sentence)
    end
  end

  def amount=(amount)
    @amount =
      begin
        Integer(amount.strip) * 100
      rescue ArgumentError
        0
      end
  end

  def charity=(charity)
    @charity = Charity.find_by(id: charity)
  end

  private

  def build_result(status, errors = nil)
    BuildResult.new(success: status == :success, errors: errors)
  end

  def charge_params
    {
      amount: amount,
      currency: App::DEFAULT_CURRENCY,
      card: omise_token,
      description: "Donation to #{charity.name} [#{charity.id}]"
    }
  end

  def minimum_amount_in_cents
    return if amount > MIN_AMOUNT_CENTS

    errors.add(
      :amount,
      :greater_than_or_equal_to,
      count: Money.new(MIN_AMOUNT_CENTS).to_i
    )
  end
end
