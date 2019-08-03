module OmiseMock
  def stub_create_charge(success: true, error: false)
    stub_create = lambda do |params|
      if error
        raise Omise::Error.new(
          'message' => "token #{params[:card]} was not found",
          'code' => 'not_found'
        )
      else
        OpenStruct.new(
          amount: params[:amount].to_i,
          paid: success,
        )
      end
    end
    Omise::Charge.stub(:create, stub_create) do
      yield
    end
  end

  def stub_token_retrieve
    stub_retrieve = lambda do |token|
      OpenStruct.new(
        id: token,
        card: OpenStruct.new(
          name: 'J DOE',
          last_digits: '4242',
          expiration_month: 10,
          expiration_year: 2020,
          security_code_check: false,
        )
      )
    end
    Omise::Token.stub(:retrieve, stub_retrieve) do
      yield
    end
  end
end
