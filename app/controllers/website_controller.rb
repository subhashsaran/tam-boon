class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    create_charge = CreateCharge.new(charge_params).call

    if create_charge.success?
      flash.notice = t('.success')
      redirect_to root_path
    else
      @token = retrieve_token(charge_params[:omise_token])
      flash.now.alert = create_charge.errors
      render :index
    end
  end

  private

  def charge_params
    params.permit(:omise_token, :charity, :amount)
  end

  def retrieve_token(token)
    Omise::Token.retrieve(token)
  end
end
