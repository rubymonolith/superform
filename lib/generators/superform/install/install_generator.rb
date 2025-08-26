require "bundler"

class Superform::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def check_phlex_rails_dependency
    unless gem_in_bundle?("phlex-rails")
      say "ERROR: phlex-rails is not installed. Please run 'bundle add phlex-rails' first.", :red
      exit 1
    end
  end

  def create_application_form
    template "base.rb", Rails.root.join("app/components/form.rb")
  end

  private

  def gem_in_bundle?(gem_name)
    Bundler.load.specs.any? { |spec| spec.name == gem_name }
  end
end