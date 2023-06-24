# Superform

Superform aims to be the best way to build forms in Rails applications. Here's what it does differently.

* **Everything is a component.** Superform is built on top of [Phlex](https://phlex.fun), so every bit of HTML in the form can be customized to your precise needs. Use it with your own CSS Framework or go crazy customizing every last bit of TailwindCSS.

* **Automatic strong parameters.** Superform automatically permits the form fields for you so you don't have to facepalm yourself after adding a form field, wondering why it doesn't persist, only to realize you forgot to add the parameter to your controller. No more! Superform was architected with safety in mind, meaining it can automatically permit your form parameters.

* **Compose complex forms with Plain 'ol Ruby Objects.** Superform is built on top of POROs, so you can easily compose forms together to create complex forms. You can even extend forms to create new forms with a different look and feel.

It's a complete rewrite of Rails form's internals that's inspired by Reactive component system.

## Installation

> **Note**
> This doesn't actually work yet. There is working source code at https://github.com/rocketshipio/oxidizer-demo/tree/main/app/views/superform that's being extracted into a gem. This repo and README exist to validate some ideas before the gem is finalized and published.

Install the gem and add to the Rails application's Gemfile by executing:

    $ bundle add superform

## Usage

Superform streamlines the development of forms on Rails applications by making everything a component.

Here's what a Superform looks in your Erb files.

```ruby
<%= render ApplicationForm.for_model @user do
      render field(:email).input(type: :email)
      render field(:name).input

      button(type: :submit) { "Sign up" }
    end %>
```

That's very spartan form! Let's add labels and HTML between each form row so we have something that looks much better.

```ruby
<%= render ApplicationForm.for_model @user do
      div class: "form-row" do
        render field(:email).label
        render field(:email).input(type: :email)
      end
      div class: "form-row" do
        render field(:name).label
        render field(:name).input
      end

      button(type: :submit) { "Sign up" }
    end %>
```

Jumpin' Jimmidy! That's form is starting to look pretty darn busy. Let's add some methods and components to the `ApplicationForm` class and tighten things up.

## Customizing the look, feel, and behavior of Superforms

Superforms are built entirely out of Phlex components. The method names correspeond with the tag, its arguments are attributes, and the blocks are the contents of the element.

```ruby
class ApplicationForm < Superform::Base
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

```ruby
<%= render ApplicationForm.for_model @user do
      labeled field(:name).input
      labeled field(:email).input(type: :email)

      submit "Sign up"
    end %>
```

Much better!

### Extending Superforms

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

```ruby
<%= render AdminForm.for_model @user do
      labeled field(:name).tooltip_input
      labeled field(:email).tooltip_input(type: :email)

      submit "Save"
    end %>
```

Since Superforms are just Ruby objects, you can organize them however you want. You can keep your view component classes embedded in your Superform file if you prefer for everythign to be in one place, keep the forms in the `app/views/forms/*.rb` folder and the components in `app/views/forms/**/*_component.rb`, use Ruby's `include` and `extend` features to modify different form classes, or put them in a gem and share them with an entire organization or open source community. It's just Ruby code!

### Automatic strong parameters

Guess what? Superform also permits form fields for you in your controller, like this:

```ruby
class UserController < ApplicationController
  # Your actions

  private

  def permitted_params
    @form.permit params
  end
end
```

To do that though you need to move the form as an inline class into your controller or `app/views` folder, which is pretty easy:

```ruby
class UsersController < ApplicationController
  # You could also put this in `./app/views/users/form.rb`
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

## Comparisons

Rails ships with a lot of great options to make forms. Many of these inspired Superform. The tl;dr:

1. Rails has a lot of great form helpers. Simple Form and Formtastic both have concise ways of defining HTML forms, but do require frequently opening and closing Erb tags.

2. Superform is uniquely capable of permitting its own controller parameters, leaving you with one less thing to worry about and test. Additionally it can be extended, shared, and modularized since its Plain' 'ol Ruby, which opens up a world of TailwindCSS form libraries and proprietary form libraries developed internally by organizations.

### Rails form helpers

Rails form helpers have lasted for almost 20 years and are super solid, but things get tricky when your application starts to take on different styles of forms. To manage it all you have to cobble together helper methods, partials, and templates. Additionally, the structure of the form then has to be expressed to the controller as strong params, forcing you to repeat yourself.

With Simpleform, you build the entire form with Ruby code, so you avoid the Erb gymnastics and helper method soup that it takes in Rails to scale up forms in an organization.

### Simple Form

I built some pretty amazing applications with Simple Form and admire its syntax. It requires "Erb soup", which is an opening and closing line of Erb per line. If you follow a specific directory structure or use their component framework, you can get pretty far, but you'll hit a wall when you need to start putting wrappers around forms or inputs.

https://github.com/heartcombo/simple_form#the-wrappers-api

The API is there, but when you change the syntax, you have to reboot the server to see the changes. UI development should be reflected immediately when the page is reloaded, which is what Superforms can do.

Like Rails form helpers, it doesn't self-permit parameters.

https://www.ruby-toolbox.com/projects/simple_form

### Formtastic

Formtastic gives us a nice DSL inside of Erb that we can use to create forms, but like Simple Form, there's a lot of opening and closing Erb tags that make the syntax clunky.

It has generators that give you Ruby objects that represent HTML form inputs that you can customize, but its limited to very specific parts of the HTML components. Superform lets you customize every aspect of the HTML in your form elements.

It also does not permit its own parameters.

https://www.ruby-toolbox.com/projects/formtastic

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/superform. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rubymonolith/superform/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Superform project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rubymonolith/superform/blob/main/CODE_OF_CONDUCT.md).
