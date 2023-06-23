# Superform

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/superform`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Install the gem and add to the Rails application's Gemfile by executing:

    $ bundle add superform

## Usage

Super Forms streamlines the development of forms on Rails applications by making everything a component.

Here's what a SuperForm looks in your Erb files.

```erb
<%= render ApplicationForm.new model: @user do
  render field(:email).input(type: :email)
  render field(:name).input

  button(type: :submit) { "Sign up" }
end %>
```

That's very spartan form! Let's add labels and HTML between each form row so we have something to work with.

```erb
<%= render ApplicationForm.new do
  div class: "form-row" do
    render field(:email).label
    render field(:email).input(type: :email)
  end
  div class: "form-row" do
    render field(:name).label
    render field(:name).input
  end

  button(type: :submit) { "Sign up" }
%>
```

Jumpin' Jimmidy! That's starting to get verbose. Let's add some helpers to `ApplicationForm` and tighten things up.

## Customizing Look & Feel

SuperForms are built entirely out of Phlex components. The method names correspeond with the tag, its arguments are attributes, and the blocks are the contents of the element.

```ruby
class ApplicationForm < SuperForm::Base
  class MyInputComponent < ApplicationComponent
    def template(&)
      div class: "form-field" do
        input(**attributes)
        if field.errors?
          p(class: "form-field-error") { field.errors.to_sentence }
        end
      end
    end
  end

  class Field < Field
    def input(**attributes)
      MyInputComponent.new(self, attributes: attributes)
    end
  end

  def labeled(component)
    div class: "form-row" do
      render component.field.label
      render component
    end
  end

  def submit(text)
    button(type: :submit) { text }
  end
end
```

That looks like a LOT of code, and it is, but look at how easy it is to create forms.

```erb
<%= render ApplicationForm.new model: @user do
  labeled field(:name).input
  labeled field(:email).input(type: :email)

  submit "Sign up"
end %>
```

Much better!

### Extending Forms

The best part? If you have forms with a completely different look and feel, you can extend the forms just like you would a Ruby class:

```ruby
class AdminForm < ApplicationForm
  class AdminInput < ApplicationComponent
    def template(&)
      input(**attributes)
      small { admin_tool_tip_for field.key }
    end
  end

  class Field < Field
    def tooltip_input(**attributes)
      AdminInput.new(self, attributes: attributes)
    end
  end
end
```

Then, just like you did in your Erb, you create the form:

```erb
<%= render AdminForm.new model: @user do
  labeled field(:name).tooltip_input
  labeled field(:email).tooltip_input(type: :email)

  submit "Save"
end %>
```

### Self-permitting Parameters

Guess what? It also permits form fields for you in your controller, like this:

```ruby
class UserController < ApplicationController
  # Your actions

  private

  def permitted_params
    @form.permit params
  end
end
```

To do that though you need to move the form into your controller, which is pretty easy:

```ruby
class UserController < ApplicationController
  class Form < ApplicationForm
    render field(:email).input(type: :email)
    render field(:name).input

    button(type: :submit) { "Sign up" }
  end

  before_action :assign_form

  # Your actions

  private

  def assign_form
    @form = Form.new(model: @user)
  end

  def permitted_params
    @form.permit params
  end
end
```

Then render it from your Erb in less lines, like this:

```
<%= render @form %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/superform. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rubymonolith/superform/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Superform project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rubymonolith/superform/blob/main/CODE_OF_CONDUCT.md).
