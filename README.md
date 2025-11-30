# Superform

**The best Rails form library.** Whether you're using ERB, HAML, or Phlex, Superform makes building forms delightful.

* **No more strong parameters headaches.** Add a field to your form and it automatically gets permitted. Never again wonder why your new field isn't saving. Superform handles parameter security for you.

* **Works beautifully with ERB.** Start using Superform in your existing Rails app without changing a single ERB template. All the power, zero migration pain.

* **Concise field helpers.** `field(:publish_at).date`, `field(:email).email`, `field(:price).number` — intuitive methods that generate the right input types with proper validation.

* **RESTful controller helpers** Superform's `save` and `save!` methods work exactly like ActiveRecord, making controller code predictable and Rails-like.

Superform is a complete reimagining of Rails forms, built on solid Ruby foundations with modern component architecture under the hood.

[![Maintainability](https://api.codeclimate.com/v1/badges/0e4dfe2a1ece26e3a59e/maintainability)](https://codeclimate.com/github/rubymonolith/superform/maintainability) [![Ruby](https://github.com/rubymonolith/superform/actions/workflows/main.yml/badge.svg)](https://github.com/rubymonolith/superform/actions/workflows/main.yml)

## Video course

Support this project and [become a Superform pro](https://beautifulruby.com/phlex/forms/introduction) by ordering the [Phlex on Rails video course](https://beautifulruby.com/phlex).

[![](https://immutable.terminalwire.com/hmM9jvv7yF89frBUfjikUfRmdUsTVZ8YvXc7OnnYoERXfLJLzDcj5dFM7qdfMG2bqQLuw633Zt1gl3O7z0zKmH6k8QmifN7z0kJo.png)](https://beautifulruby.com/phlex/forms/introduction)

## Installation

Add to the Rails application's Gemfile by executing:

    $ bundle add superform

Then install it.

    $ rails g superform:install

This will install both Phlex Rails and Superform.

## Usage

### Start with inline forms in your ERB templates

Superform works instantly in your existing Rails ERB templates. Here's what a form for a blog post might look like:

```erb
<!-- app/views/posts/new.html.erb -->
<h1>New Post</h1>

<%= render Components::Form.new @post do
  it.Field(:title).text
  it.Field(:body).textarea
  it.Field(:publish_at).date
  it.Field(:featured).checkbox
  it.submit "Create Post"
end %>
```

The form automatically generates proper Rails form tags, includes CSRF tokens, and handles validation errors.

Notice anything missing? Superform doesn't need `<% %>` tags around every single line, unlike all other Rails form helpers.

### Extract inline forms to dedicated classes to use in other views

You probably want to use the same form for creating and editing resources. In Superform, you extract forms into their own Ruby classes right along with your views.

```ruby
# app/views/posts/form.rb
class Views::Posts::Form < Components::Form
  def view_template
    Field(:title).text
    Field(:body).textarea(rows: 10)
    Field(:publish_at).date
    Field(:featured).checkbox
    submit
  end
end
```

Then render this in your views:

```erb
<!-- app/views/posts/new.html.erb -->
<h1>New Post</h1>
<%= render Views::Posts::Form.new @post %>
```

Cool, but you're about to score a huge benefit from extracting forms into their own Ruby classes with automatic strong parameters.

### Automatically permit strong parameters with form classes

Include `Superform::Rails::StrongParameters` in your controllers for automatic parameter handling:

```ruby
class PostsController < ApplicationController
  include Superform::Rails::StrongParameters

  def create
    @post = Post.new
    if save Views::Posts::Form.new(@post)
      redirect_to @post, notice: 'Post created!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ... other actions ...
end
```

The `save` method automatically:
- Permits only the parameters defined in your form
- Assigns them to your model
- Attempts to save the model
- Returns `true` if successful, `false` if validation fails

Use `save!` for the bang version that raises exceptions on validation failure or `permit` if you want to assign parameters to a model without saving it.

### Concise HTML5 form helpers

Superform includes helpers for all HTML5 input types:

```ruby
class UserForm < Components::Form
  def view_template
    Field(:email).email           # type="email"
    Field(:password).password     # type="password"
    Field(:website).url           # type="url"
    Field(:phone).tel             # type="tel"
    Field(:age).number(min: 18)   # type="number"
    Field(:birthday).date         # type="date"
    Field(:appointment).datetime  # type="datetime-local"
    Field(:favorite_color).color  # type="color"
    Field(:bio).textarea(rows: 5)
    Field(:terms).checkbox
    submit
  end
end
```

### Works great with Phlex

Superform was built from the ground-up using Phlex components, which means you'll feel right at home using it with your existing Phlex views and components.

```ruby
class Views::Posts::Form < Components::Form
  def view_template
    div(class: "form-section") do
      h2 { "Post Details" }
      Field(:title).text(class: "form-control")
      Field(:body).textarea(class: "form-control", rows: 10)
    end

    div(class: "form-section") do
      h2 { "Publishing" }
      Field(:publish_at).date(class: "form-control")
      Field(:featured).checkbox(class: "form-check-input")
    end

    div(class: "form-actions") do
      submit "Save Post", class: "btn btn-primary"
    end
  end
end
```

This gives you complete control over markup, styling, and component composition while maintaining all the strong parameter and validation benefits.

## Customization

Superforms are built out of [Phlex components](https://www.phlex.fun/html/components/). The method names correspond with the HTML tag, its arguments are attributes, and the blocks are the contents of the tag.

```ruby
# ./app/components/form.rb
class Components::Form < Superform::Rails::Form
  class MyInput < Superform::Rails::Components::Input
    def view_template(&)
      div class: "form-field" do
        input(**attributes)
      end
    end
  end

  # Redefining the base Field class lets us override every field component.
  class Field < Superform::Rails::Form::Field
    def input(**attributes)
      MyInput.new(self, attributes: attributes)
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
class Users::Form < Components::Form
  def view_template(&)
    labeled Field(:name).input
    labeled Field(:email).input(type: :email)

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
      owner.Field(:name).text
      # Renders input with the name `account[owner][email]`
      owner.Field(:email).email
    end

    # Account#members returns a collection of objects
    collection(:members).each do |member|
      # Renders input with the name `account[members][0][name]`,
      # `account[members][1][name]`, ...
      member.Field(:name).input
      # Renders input with the name `account[members][0][email]`,
      # `account[members][1][email]`, ...
      member.Field(:email).input(type: :email)

      # Member#permissions returns an array of values like
      # ["read", "write", "delete"].
      member.field(:permissions).collection do |permission|
        # Renders input with the name `account[members][0][permissions][]`,
        # `account[members][1][permissions][]`, ...
        render permission.label do
          plain permission.value.humanize
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
    render Field(:email).input
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
    render Field(:email).input
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
class SignupForm < Components::Form
  def view_template
    # The most basic type of input, which will be autofocused.
    Field(:name).input.focus

    # Input field with a lot more options on it.
    Field(:email).input(type: :email, placeholder: "We will sell this to third parties", required: true)

    # You can put fields in a block if that's your thing.
    field(:reason) do |f|
      div do
        render f.label { "Why should we care about you?" }
        render f.textarea(row: 3, col: 80)
      end
    end

    # Selects accept options as positional arguments. Each option can be:
    # - A 2-element array: [value, label] renders <option value="value">label</option>
    # - A single value: "text" renders <option value="text">text</option>
    # - nil: renders an empty <option></option>
    div do
      Field(:contact).label { "Would you like us to spam you to death?" }
      Field(:contact).select(
        [true, "Yes"],  # <option value="true">Yes</option>
        [false, "No"],  # <option value="false">No</option>
        "Hell no",      # <option value="Hell no">Hell no</option>
        nil             # <option></option>
      )
    end

    div do
      Field(:source).label { "How did you hear about us?" }
      Field(:source).select do |s|
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

    # Pass nil as first argument to add a blank option at the start
    div do
      Field(:country).label { "Select your country" }
      Field(:country).select(nil, [1, "USA"], [2, "Canada"], [3, "Mexico"])
    end

    # Multiple select with multiple: true
    # - Adds the HTML 'multiple' attribute
    # - Appends [] to the field name (role_ids becomes role_ids[])
    # - Includes a hidden input to handle empty submissions
    div do
      Field(:role_ids).label { "Select roles" }
      Field(:role_ids).select(
        [[1, "Admin"], [2, "Editor"], [3, "Viewer"]],
        multiple: true
      )
    end

    # Combine multiple: true with nil for blank option
    div do
      Field(:tag_ids).label { "Select tags (optional)" }
      Field(:tag_ids).select(
        nil, [1, "Ruby"], [2, "Rails"], [3, "Phlex"],
        multiple: true
      )
    end

    # Select options can also be ActiveRecord relations
    # The relation is passed as a single argument (not splatted)
    # OptionMapper extracts the primary key and joins other attributes for the label
    div do
      Field(:author_id).label { "Select author" }
      # For User.select(:id, :name), renders <option value="1">Alice</option>
      # where id=1 is the primary key and "Alice" is the name attribute
      Field(:author_id).select(User.select(:id, :name))
    end

    div do
      Field(:agreement).label { "Check this box if you agree to give us your first born child" }
      Field(:agreement).checkbox(checked: true)
    end

    render button { "Submit" }
  end
end
```

### Upload fields
If you want to add file upload fields to your form you will need to initialize your form with the `enctype` attribute set to `multipart/form-data` as shown in the following example code:

```ruby
class User::ImageForm < Components::Form
  def view_template
    # render label
    Field(:image).label { "Choose file" }
    # render file input with accept attribute for png and jpeg images
    Field(:image).input(type: "file", accept: "image/png, image/jpeg")
  end
end

# IMPORTANT
# When rendering the form remember to init the User::ImageForm like that
render User::ImageForm.new(@usermodel, enctype: "multipart/form-data")
```


## Extending Superforms

The best part? If you have forms with a completely different look and feel, you can extend the forms just like you would a Ruby class:

```ruby
class AdminForm < Components::Form
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
    labeled Field(:name).tooltip_input
    labeled Field(:email).tooltip_input(type: :email)

    submit "Save"
  end
end
```

Since Superforms are just Ruby objects, you can organize them however you want. You can keep your view component classes embedded in your Superform file if you prefer for everything to be in one place, keep the forms in the `app/components/forms/*.rb` folder and the components in `app/components/forms/**/*_component.rb`, use Ruby's `include` and `extend` features to modify different form classes, or put them in a gem and share them with an entire organization or open source community. It's just Ruby code!

## Automatic strong parameters

Superform eliminates the need to manually define strong parameters. Just include `Superform::Rails::StrongParameters` in your controllers and use the `save`, `save!`, and `permit` methods:

```ruby
class PostsController < ApplicationController
  include Superform::Rails::StrongParameters
  include Views::Posts

  # Standard Rails CRUD with automatic strong parameters
  def create
    @post = Post.new
    if save Form.new(@post)
      redirect_to @post, notice: 'Post created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find(params[:id])
    if save! Form.new(@post)
      redirect_to @post, notice: 'Post updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # For cases where you want to assign params without saving
  def preview
    @post = Post.new
    permit Form.new(@post)  # Assigns params but doesn't save
    render :preview
  end
end
```

**How it works:** Superform automatically permits only the parameters that correspond to fields defined in your form. Attempts to mass-assign other parameters are safely ignored, protecting against parameter pollution attacks.

**Available methods:**
- `save(form)` - Assigns permitted params and saves the model, returns `true`/`false`
- `save!(form)` - Same as `save` but raises exception on validation failure
- `permit(form)` - Assigns permitted params without saving, returns the model

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
