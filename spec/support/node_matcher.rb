# frozen_string_literal: true

RSpec::Matchers.define :render_node do |expected|
  match do |actual|
    css = actual.css(expected)
    @actual = actual.to_s

    puts @actual
    !css.empty?
  end

  chain :with_attrs do |expected_attrs|
    @expected_attrs = expected_attrs
  end

  diffable
end

RSpec::Matchers.define :have_attrs do |expected|
  match do |actual|
    expected.each do |attr, value|
      attr = actual.attr(attr)

      attr && values_match?(attr.value, value)
    end
  end
end

RSpec::Matchers.define :render_nodes do |*expected|
  match do |actual|
    css = expected.map do |exp|
      actual.css(exp)
    end
    @actual = actual.to_s
    css.none?(&:empty?)
  end

  diffable
end
