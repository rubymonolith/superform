## [Unreleased]

### Breaking Changes

This release includes several breaking changes to improve consistency with Phlex 2.x conventions and better organize the codebase.

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

1. **Update component class names** in your custom form classes:

   ```ruby
   # Before (0.5.x)
   class MyInput < Superform::Rails::Components::InputComponent
     # ...
   end

   class Field < Superform::Rails::Form::Field
     def input(**attributes)
       MyInputComponent.new(self, attributes: attributes)
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

2. **Update your Gemfile** to ensure compatibility:

   ```ruby
   gem 'phlex-rails', '~> 2.0'
   gem 'superform', '~> 0.6.0'
   ```

3. **Run bundle update** to update dependencies:

   ```bash
   bundle update phlex-rails superform
   ```

### Added

- Better file organization with Rails classes in separate files
- Improved Phlex 2.x compatibility and conventions

### Changed

- Rails component classes moved to individual files
- Component class names simplified to match Phlex conventions
- Dependency updated to require phlex-rails 2.x

## [0.1.0] - 2023-06-23

- Initial release
