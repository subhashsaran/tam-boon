class BuildResult
  attr_reader :errors

  def initialize(success:, errors: nil)
    @success = success
    @errors = errors
  end

  def success?
    @success
  end
end
