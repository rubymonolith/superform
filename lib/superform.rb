require "zeitwerk"
require "superform/dom"
require "superform/node"
require "superform/namespace"
require "superform/field"
require "superform/field_collection"
require "superform/namespace_collection"

module Superform
  Loader = Zeitwerk::Loader.for_gem.tap do |loader|
    loader.ignore "#{__dir__}/generators"
    loader.setup
  end

  class Error < StandardError; end
end

def Superform(...)
  Superform::Namespace.root(...)
end
