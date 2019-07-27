class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    with_lock do
      reload
      updated_total = total + amount
      update(total: updated_total)
    end
  end
end
