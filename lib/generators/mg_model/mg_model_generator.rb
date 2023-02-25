# frozen_string_literal: true

require_relative 'input_checks.rb'
require 'prettyprint'
require_relative 'custom_prompts'
require_relative 'column'

# MgModelGenerator is a wrapper around the command line model generator
class MgModelGenerator < Rails::Generators::NamedBase
  include InputChecks
  include CustomPrompts
  attr_accessor :columns, :columns_complete

  def initialize(args, *options)
    @model_name = args[0]
    @columns = []
    @columns_complete = false
    super
  end

  def request_columns
    build_column until columns_complete?
  end

  def present_columns
    columns.map(&:pretty_print)
  end

  def build_commandline
    columns.reduce { |col, r| " #{col.build_commandline}"}
  end

  def ask_modifications
    puts 'mods???'
  end

  private

  def build_column
    name = ask_column_name
    return if columns_complete?(name)

    columns << Column.build_column(name)
  end

  # @param input [String, NilClass]
  # @return [Boolean]
  def columns_complete?(input = nil)
    return @columns_complete unless input

    @columns_complete = done?(input)
  end





  def ask_column_name
    ask_question("column name ('D/d' for done):")
  end

  def complete?(question = 'complete?')
    complete = ask question
    %w[t T TRUE True true y Y YES yes Yes d D DONE Done].include?(complete)
  end
end
