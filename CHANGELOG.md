## [Unreleased]

## [0.6.1] - 2025-08-28

### Breaking Changes

This release includes several breaking changes to improve consistency with Phlex 2.x conventions and better organize the codebase.

#### Form Instance Architecture Changes

The framework now passes form instances instead of field classes throughout the namespace hierarchy:

- `Namespace` constructor now accepts `form:` parameter instead of `field_class:`
- `NamespaceCollection` constructor now accepts `form:` parameter instead of `field_class:`
- Form instances must implement a `build_field` method for field creation
- Rails forms now pass themselves as form instances to namespaces

This change enables better encapsulation and allows forms to customize field creation logic.

#### Component Class Naming Changes

All Rails component classes have been renamed to match Phlex 2.x conventions by removing the "Component" suffix:

- `Superform::Rails::Components::BaseComponent` → `Superform::Rails::Components::Base`
- `Superform::Rails::Components::FieldComponent` → `Superform::Rails::Components::Field`
- `Superform::Rails::Components::InputComponent` → `Superform::Rails::Components::Input`
- `Superform::Rails::Components::ButtonComponent` → `Superform::Rails::Components::Button`
- `Superform::Rails::Components::CheckboxComponent` → `Superform::Rails::Components::Checkbox`
- `Superform::Rails::Components::TextareaComponent` → `Superform::Rails::Components::Textarea`
- `Superform::Rails::Components::SelectField` → `Superform::Rails::Components::Select`
- `Superform::Rails::Components::LabelComponent` → `Superform::Rails::Components::Label`

#### File Structure Changes

Rails classes have been moved into separate files for better organization:

- Components are now in individual files under `lib/superform/rails/components/`
- Core classes like `Form` are now in `lib/superform/rails/form.rb`

#### Phlex Rails Dependency

- Now requires `phlex-rails ~> 2.0` (was `>= 1.0, < 3.0`)

### How to Upgrade

#### Phlex 2.x compatibility

The `ApplicationForm` file should be moved to `Components::Form` at `./app/components/form.rb` to better match Phlex 2.x conventions.

   ```ruby
   # Before (0.5.x)
   class ApplicationForm < Superform::Rails::Form
     # ...
   end
   ```

   ```ruby
   # After (0.6.0)
   class Components::Form < Superform::Rails::Form
     # ...
   end
   ```

Form variants may organized in the `./app/components/forms/` directory.

   ```ruby
   # Before (0.5.x)
   class Forms::User < ApplicationForm
     # ...
   end
   ```

   ```ruby
   # After (0.6.0)
   class Forms::User < Components::Form
     # ...
   end
   ```

#### Custom Form Classes

Custom form classes with Rails now automatically pass themselves as form instances (no changes needed for basic usage).

#### Update Component Class Names

Update component class names in your custom form classes:

   ```ruby
   # Before (0.5.x)
   class MyInput < Superform::Rails::Components::InputComponent
     # ...
   end

   class Field < Superform::Rails::Form::Field
     def input(**attributes)
       MyInput.new(self, attributes: attributes)
     end
   end
   ```

   ```ruby
   # After (0.6.0)
   class MyInput < Superform::Rails::Components::Input
     # ...
   end

   class Field < Superform::Rails::Form::Field
     def input(**attributes)
       MyInput.new(self, attributes: attributes)
     end
   end
   ```

#### Update Your Gemfile

Update your Gemfile to ensure compatibility:

   ```ruby
   gem 'phlex-rails', '~> 2.0'
   gem 'superform', '~> 0.6.0'
   ```

#### Run Bundle Update

Run bundle update to update dependencies:

   ```bash
   bundle update phlex-rails superform
   ```

### Added

- Form instance architecture for better encapsulation and customization
- `Superform::Form` class for basic form behavior without Rails dependencies
- `build_field` method delegation to form instances
- Better file organization with Rails classes in separate files
- Improved Phlex 2.x compatibility and conventions
- Strong Parameters support with `Superform::Rails::StrongParameters` module:
  - `permit(form)` method for assigning permitted params without saving
  - `save(form)` method for saving models with permitted params
  - `save!(form)` method for saving with exception handling on validation failure
  - Automatic parameter filtering based on form field declarations
  - Safe mass assignment protection against unauthorized attributes
- Field input type helper methods for Rails forms:
  - `field.email` for email input type
  - `field.password` for password input type
  - `field.url` for URL input type
  - `field.tel` (with `phone` alias) for telephone input type
  - `field.number` for number input type
  - `field.range` for range input type
  - `field.date` for date input type
  - `field.time` for time input type
  - `field.datetime` for datetime-local input type
  - `field.month` for month input type
  - `field.week` for week input type
  - `field.color` for color input type
  - `field.search` for search input type
  - `field.file` for file input type
  - `field.hidden` for hidden input type
  - `field.radio(value)` for radio button input type

### Changed

- **Breaking**: `Namespace` and `NamespaceCollection` constructors now accept `form:` instead of `field_class:`
- **Breaking**: Form instances must implement `build_field` method
- Rails component classes moved to individual files
- Component class names simplified to match Phlex conventions
- Dependency updated to require phlex-rails 2.x

## [0.1.0] - 2023-06-23

- Initial release
