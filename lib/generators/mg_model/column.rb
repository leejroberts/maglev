# frozen_string_literal: true

require 'pp'
require_relative 'custom_prompts'

class Column
  include CustomPrompts
  attr_reader :name, :type, :options

  COLUMN_TYPES = %w[
    string
    text
    reference
    integer
    float
    decimal
    boolean
    date
    time
    datetime
    timestamp
    binary
    primary_key
  ].freeze

  # @param name [String]
  def initialize(name)
    @name = name
    @type = nil
    @options = {}
  end

  def self.build_column(name)
    column = new(name)
    column.build_column
    column
  end

  def build_column
    set_type
    type_modifiers.each do |modifier_method|
      send(modifier_method)
      pretty_print
    end
  end

  # @return [Array<Symbol>]
  def type_modifiers
    case type
    when 'string', 'text', 'integer', 'binary'
      %i[set_limit set_default set_null set_index]
    when 'float', 'jsonb'
      %i[set_default set_null]
    when 'decimal'
      %i[set_scale set_precision set_default set_null]
    when 'references'
      %i[set_polymorphic set_foreign_key set_null]
    else # handles date, time, datetime and all the things I missed
      %i[set_null set_index]
    end
  end

  def pretty_print
    pp [name, type, options]
  end

  private

  def to_hash
    {
      name: @name,
      type: @type,
      options: @options
    }.compact
  end

  def set_index
    response = prompt.select("#{@name} index:", ['None', 'Standard', "Unique"], filter: true, per_page: 100, show_help: :always)
    { "None" => nil,
      "Standard" => :index,
      "Unique" => :unique
    }[response]
  end

  def set_uniq
    @options[:uniq] = prompt.yes?("does #{@name} require a GLOBAL uniq value?")
  end

  def set_precision
    @options[:precision] = ask_precision_value
  end

  def set_scale
    @options[:scale] = ask_scale_value
  end

  def set_default
    @options[:default] = ask_default_value
  end

  def set_limit
    @options[:limit] = ask_integer("#{@name}: char limit or maximum size (s/S to skip):")
  end

  def set_type
    @type = select_column_type
  end

  def set_null
    @options[:null] = prompt.yes?("#{@name}: allow null values?")
  end

  def select_column_type
    prompt.select('column type:', COLUMN_TYPES, filter: true, per_page: 100, show_help: :always)
  end

  def ask_default_value
    case type
    when %w(integer float decimal)
      ask_numerical("#{@name} default value: (s/S to skip)", convert: @type == "decimal" ? :float : @type.to_sym)
    when 'boolean'
      ask_boolean_default
    else # string, text, binary
      ask_question("#{@name} default value: ('' or \"\" for empty string) (s/S to skip)")
    end
  end

  def ask_boolean_default
    response = prompt.select("#{@name} default value:", %w[None true false])
    { "None" => nil,
      "true" => true,
      "false" => false
    }[response]
  end

  # command line syntax 'price:decimal{5,2}' precision of 5 scale of two eg; 100.02
  def ask_precision_value
    ask_integer("#{@name} precision or total number of digits in the number (s/S to skip:")
  end

  def ask_scale_value
    ask_integer("#{@name} scale or total number of digits AFTER the decimal (s/S to skip):")
  end

  def ask_integer(string)
    ask_numerical(string, convert: :integer)
  end
end
