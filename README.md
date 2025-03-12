# Superform

Superform aims to be the best way to build forms in Rails applications. Here's what it does differently.

* **Everything is a component.** Superform is built on top of [Phlex](https://phlex.fun), so every bit of HTML in the form can be customized to your precise needs. Use it with your own CSS Framework or go crazy customizing every last bit of TailwindCSS.

* **Automatic strong parameters.** Superform automatically permits form fields so you don't have to facepalm yourself after adding a field, wondering why it doesn't persist, only to realize you forgot to add the parameter to your controller. No more! Superform was architected with safety & security in mind, meaning it can automatically permit your form parameters.

* **Compose complex forms with Plain 'ol Ruby Objects.** Superform is built on top of POROs, so you can easily compose classes, modules, & ruby code together to create complex forms. You can even extend forms to create new forms with a different look and feel.

It's a complete rewrite of Rails form's internals that's inspired by Reactive component design patterns.

[![Maintainability](https://api.codeclimate.com/v1/badges/0e4dfe2a1ece26e3a59e/maintainability)](https://codeclimate.com/github/rubymonolith/superform/maintainability) [![Ruby](https://github.com/rubymonolith/superform/actions/workflows/main.yml/badge.svg)](https://github.com/rubymonolith/superform/actions/workflows/main.yml)

## Video course

Support this project and [become a Superform pro](https://beautifulruby.com/phlex/forms/overview) by ordering the [Phlex on Rails video course](https://beautifulruby.com/phlex).

[![](https://immutable.terminalwire.com/NgTt6nzO1aEnExV8j6ODuKt2iZpY74ZF8ecpUSCp4A0tXA0ErpJIS4cdMX0tQQKOWwZSl65jWnpzpgCLJThhhWtZJGr42XKt7WIi.png)](https://beautifulruby.com/phlex/forms/overview)

## Installation

Add to the Rails application's Gemfile by executing:

    $ bundle add superform

Then install it.

    $ rails g superform:install

This will install both Phlex Rails and Superform.

## Usage

Superform streamlines the development of forms on Rails applications by making everything a component.

After installing, create a form in `app/views/*/form.rb`. For example, a form for a `Post` resource might look like this.

```ruby
# ./app/views/posts/form.rb
class Posts::Form < ApplicationForm
  def view_template(&)
    labeled field(:title).input
    labeled field(:body).textarea
    labeled field(:blog).select Blog.select(:id, :title)
  end
end
```

Then render it in your templates. Here's what it looks like from an Erb file.

```erb
<h1>New post</h1>
<%= render Posts::Form.new @post %>
```

## Customization

Superforms are built out of [Phlex components](https://www.phlex.fun/html/components/). The method names correspond with the HTML tag, its arguments are attributes, and the blocks are the contents of the tag.

```ruby
# ./app/views/forms/application_form.rb
class ApplicationForm < Superform::Rails::Form
  class MyInputComponent < Superform::Rails::Components::InputComponent
    def view_template(&)
      div class: "form-field" do
        input(**attributes)
      end
    end
  end

  # Redefining the base Field class lets us override every field component.
  class Field < Superform::Rails::Form::Field
    def input(**attributes)
      MyInputComponent.new(self, attributes: attributes)
    end
  end

  # Here we make a simple helper to make our syntax shorter. Given a field it
  # will also render its label.
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
# ./app/views/users/form.rb
class Users::Form < ApplicationForm
  def view_template(&)
    labeled field(:name).input
    labeled field(:email).input(type: :email)

    submit "Sign up"
  end
end
```

Then render it from Erb.

```erb
<%= render Users::Form.new @user %>
```

Much better!

## Namespaces & Collections

Superform uses a different syntax for namespacing and collections than Rails, which can be a bit confusing since the same terminology is used but the application is slightly different.

Consider a form for an account that lets people edit the names and email of the owner and users of an account.

```ruby
class AccountForm < Superform::Rails::Form
  def view_template
    # Account#owner returns a single object
    namespace :owner do |owner|
      # Renders input with the name `account[owner][name]`
      render owner.field(:name).input
      # Renders input with the name `account[owner][email]`
      render owner.field(:email).input(type: :email)
    end

    # Account#members returns a collection of objects
    collection(:members).each do |member|
      # Renders input with the name `account[members][0][name]`,
      # `account[members][1][name]`, ...
      render member.field(:name).input
      # Renders input with the name `account[members][0][email]`,
      # `account[members][1][email]`, ...
      render member.field(:email).input(type: :email)

      # Member#permissions returns an array of values like
      # ["read", "write", "delete"].
      member.field(:permissions).collection do |permission|
        # Renders input with the name `account[members][0][permissions][]`,
        # `account[members][1][permissions][]`, ...
        render permission.label do
          plain permisson.value.humanize
          render permission.checkbox
        end
      end
    end
  end
end
```

One big difference between Superform and Rails is the `collection` methods require the use of the `each` method to enumerate over each item in the collection.

There's three different types of namespaces and collections to consider:

1. **Namespace** - `namespace(:field_name)` is used to map form fields to a single object that's a child of another object. In ActiveRecord, this could be a `has_one` or `belongs_to` relationship.

2. **Collection** - `collection(:field_name).each` is used to map a collection of objects to a form. In this case, the members of the account. In ActiveRecord, this could be a `has_many` relationship.

3. **Field Collection** - `field(:field_name).collection.each` is used when the value of a field is enumerable, like an array of values. In ActiveRecord, this could be an attribute that's an Array type.

### Change a form's root namespace

By default Superform namespaces a form based on the ActiveModel model name param key.

```ruby
class UserForm < Superform::Rails::Form
  def view_template
    render field(:email).input
  end
end

render LoginForm.new(User.new)
# Renders input with the name `user[email]`

render LoginForm.new(Admin::User.new)
# Renders input with the name `admin_user[email]`
```

To customize the form namespace, like an ActiveRecord model nested within a module, the `key` method can be overriden.

```ruby
class UserForm < Superform::Rails::Form
  def view_template
    render field(:email).input
  end

  def key
    "user"
  end
end

render UserForm.new(User.new)
# Renders input with the name `user[email]`

render UserForm.new(Admin::User.new)
# This will also render inputs with the name `user[email]`
```

## Form field guide

Superform tries to strike a balance between "being as close to HTML forms as possible" and not requiring a lot of boilerplate to create forms. This example is contrived, but it shows all the different ways you can render a form.

In practice, many of the calls below you'd put inside of a method. This cuts down on the number of `render` calls in your HTML code and further reduces boilerplate.

```ruby
# Everything below is intentionally verbose!
class SignupForm < ApplicationForm
  def view_template
    # The most basic type of input, which will be autofocused.
    render field(:name).input.focus

    # Input field with a lot more options on it.
    render field(:email).input(type: :email, placeholder: "We will sell this to third parties", required: true)

    # You can put fields in a block if that's your thing.
    field(:reason) do |f|
      div do
        render f.label { "Why should we care about you?" }
        render f.textarea(row: 3, col: 80)
      end
    end

    # Let's get crazy with Selects. They can accept values as simple as 2 element arrays.
    div do
      render field(:contact).label { "Would you like us to spam you to death?" }
      render field(:contact).select(
        [true, "Yes"],  # <option value="true">Yes</option>
        [false, "No"],  # <option value="false">No</option>
        "Hell no",      # <option value="Hell no">Hell no</option>
        nil             # <option></option>
      )
    end

    div do
      render field(:source).label { "How did you hear about us?" }
      render field(:source).select do |s|
        # Renders a blank option.
        s.blank_option
        # Pretend WebSources is an ActiveRecord scope with a "Social" category that has "Facebook, X, etc"
        # and a "Search" category with "AltaVista, Yahoo, etc."
        WebSources.select(:id, :name).group_by(:category) do |category, sources|
          s.optgroup(label: category) do
            s.options(sources)
          end
        end
      end
    end

    div do
      render field(:agreement).label { "Check this box if you agree to give us your first born child" }
      render field(:agreement).checkbox(checked: true)
    end

    render button { "Submit" }
  end
end
```

### Upload fields
If you want to add file upload fields to your form you will need to initialize your form with the `enctype` attribute set to `multipart/form-data` as shown in the following example code:

```ruby
class User::ImageForm < ApplicationForm
  def view_template
    # render label
    render field(:image).label { "Choose file" }
    # render file input with accept attribute for png and jpeg images
    render field(:image).input(type: "file", accept: "image/png, image/jpeg")
  end
end

# IMPORTANT
# When rendering the form remember to init the User::ImageForm like that
render User::ImageForm.new(@usermodel, enctype: "multipart/form-data")
```


## Extending Superforms

The best part? If you have forms with a completely different look and feel, you can extend the forms just like you would a Ruby class:

```ruby
class AdminForm < ApplicationForm
  class AdminInput < Components::Base
    def view_template(&)
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
class Admin::Users::Form < AdminForm
  def view_template(&)
    labeled field(:name).tooltip_input
    labeled field(:email).tooltip_input(type: :email)

    submit "Save"
  end
end
```

Since Superforms are just Ruby objects, you can organize them however you want. You can keep your view component classes embedded in your Superform file if you prefer for everything to be in one place, keep the forms in the `app/views/forms/*.rb` folder and the components in `app/views/forms/**/*_component.rb`, use Ruby's `include` and `extend` features to modify different form classes, or put them in a gem and share them with an entire organization or open source community. It's just Ruby code!

## Automatic strong parameters

Guess what? Superform eliminates the need for Strong Parameters in Rails by assigning the values of the `params` hash _through_ your form via the `assign` method. Here's what it looks like.

```ruby
class PostsController < ApplicationController
  include Superform::Rails::StrongParameters

  def create
    @post = assign params.require(:post), to: Posts::Form.new(Post.new)

    if @post.save
      # Success path
    else
      # Error path
    end
  end

  def update
    @post = Post.find(params[:id])

    assign params.require(:post), to: Posts::Form.new(@post)

    if @post.save
      # Success path
    else
      # Error path
    end
  end
end
```

How does it work? An instance of the form is created, then the hash is assigned to it. If the params include data outside of what a form accepts, it will be ignored.

## Comparisons

Rails ships with a lot of great options to make forms. Many of these inspired Superform. The tl;dr:

1. Rails has a lot of great form helpers. Simple Form and Formtastic both have concise ways of defining HTML forms, but do require frequently opening and closing Erb tags.

2. Superform is uniquely capable of permitting its own controller parameters, leaving you with one less thing to worry about and test. Additionally it can be extended, shared, and modularized since its Plain' 'ol Ruby, which opens up a world of TailwindCSS form libraries and proprietary form libraries developed internally by organizations.

### Rails form helpers

Rails form helpers have lasted for almost 20 years and are super solid, but things get tricky when your application starts to take on different styles of forms. To manage it all you have to cobble together helper methods, partials, and templates. Additionally, the structure of the form then has to be expressed to the controller as strong params, forcing you to repeat yourself.

With Superform, you build the entire form with Ruby code, so you avoid the Erb gymnastics and helper method soup that it takes in Rails to scale up forms in an organization.

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
