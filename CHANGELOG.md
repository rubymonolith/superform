## [Unreleased]

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
- `NullForm` class for default form behavior without Rails
- `build_field` method delegation to form instances
- Better file organization with Rails classes in separate files
- Improved Phlex 2.x compatibility and conventions

### Changed

- **Breaking**: `Namespace` and `NamespaceCollection` constructors now accept `form:` instead of `field_class:`
- **Breaking**: Form instances must implement `build_field` method
- Rails component classes moved to individual files
- Component class names simplified to match Phlex conventions
- Dependency updated to require phlex-rails 2.x

## [0.1.0] - 2023-06-23

- Initial release
