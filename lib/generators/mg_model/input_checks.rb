# InputChecks checks inputs
module InputChecks
  # @param input [String]
  # @return [Boolean]
  def done?(input)
    input.downcase.strip == 'd'
  end

  # @param input [String]
  # @return [Boolean]
  def none?(input)
    input.downcase.strip == 'none'
  end

  # @param input [String]
  # @return [Boolean]
  def skip?(input)
    %w[d x none].include?(input.downcase.strip)
  end
end
