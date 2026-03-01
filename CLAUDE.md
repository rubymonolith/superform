# Superform Development Guide

## Component Argument Convention

HTML components follow a strict convention for arguments:

- **Positional/named keyword arguments** are for component configuration (non-HTML concerns)
- **`**kwargs`** are for HTML attributes that pass through to the rendered element

```ruby
# field is positional, value: is config, **attributes are HTML
class Radio < Field
  def initialize(field, value:, **attributes)
    super(field, **attributes)
    @value = value
  end
end

# options: and multiple: are config, **attributes are HTML
class Select < Field
  def initialize(field, options:, multiple: false, **attributes)
    super(field, **attributes)
    @options = options
    @multiple = multiple
  end
end
```

The Field methods mirror this: config args are explicit, HTML attributes flow through as `**kwargs`.

```ruby
def radio(value, **attributes)
  Components::Radio.new(field, value:, **attributes)
end

def select(*options, multiple: false, **attributes, &)
  Components::Select.new(field, options:, multiple:, **attributes, &)
end
```

## Key Architecture

- **Field** is a data binding object (model, key, value, DOM name) — not HTML
- **Components** are HTML elements — their kwargs should be HTML attributes
- **Form** is a Phlex component that contains fields and renders the `<form>` tag
- Customization is through subclassing, not runtime options
