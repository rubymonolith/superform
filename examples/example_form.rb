# Base class for example forms
class ExampleForm < Superform::Rails::Form
  def self.name_text
    name.gsub(/Form$/, "").gsub(/([a-z])([A-Z])/, '\1 \2')
  end

  def self.description
    ""
  end
end
