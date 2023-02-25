# frozen_string_literal: true

require 'tty-prompt'
# CustomPrompts basic set of prompts with access to prompt
module CustomPrompts
  include InputChecks

  def prompt
    @prompt ||= TTY::Prompt.new
  end

  def ask_numerical(question, convert: :integer)
    response = prompt.ask(question) do |q|
      q.modify :trim
      q.convert convert
    end
    skip?(response) ? nil : response
  end

  def ask_question(question)
    response = prompt.ask(question) { |q| q.modify :trim }
    skip?(response) ? nil : response
  end
end
