require "zeitwerk"

module Superform
  Loader = Zeitwerk::Loader.for_gem.tap do |loader|
    loader.ignore "#{__dir__}/generators"
    loader.inflector.inflect(
      'dom' => 'DOM'
    )
    loader.setup
  end

  class Error < StandardError; end
end

def Superform(...)
  Superform::Namespace.root(...)
end
