# Spec Style Guide

This document outlines the preferred testing patterns for Superform. Follow these patterns to maintain consistency and readability across the test suite.

## Generator Testing

### ✅ Preferred Pattern

Use integration-style testing that actually runs the generator:

```ruby
RSpec.describe SomeGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([], {}, { destination_root: destination_root }) }

  before do
    FileUtils.mkdir_p(destination_root)
    allow(Rails).to receive(:root).and_return(Pathname.new(destination_root))
  end

  after do
    FileUtils.rm_rf(destination_root) if File.exist?(destination_root)
  end

  context "when dependencies are met" do
    before do
      allow(generator).to receive(:gem_in_bundle?).with("some-gem").and_return(true)
    end

    it "creates the expected file" do
      generator.invoke_all
      expect(File.exist?(File.join(destination_root, "path/to/file.rb"))).to be true
    end

    describe "generated file" do
      subject { File.read(File.join(destination_root, "path/to/file.rb")) }
      
      before { generator.invoke_all }
      
      it { is_expected.to include("class SomeClass") }
      it { is_expected.to include("def some_method") }
    end
  end
end
```

### ❌ Avoid This Pattern

Don't unit test individual generator methods in isolation:

```ruby
# DON'T DO THIS
it "creates file with correct content" do
  generator.create_some_file
  
  content = File.read(file_path)
  expect(content).to include("class SomeClass")
  expect(content).to include("def some_method") 
  expect(content).to include("def another_method")
  # ... more expectations
end
```

## File Content Testing

### ✅ Use Subject Blocks

When testing generated file content, use `subject` blocks with `is_expected` matchers:

```ruby
describe "generated file" do
  subject { File.read(file_path) }
  
  before { run_generator_or_setup }
  
  it { is_expected.to include("essential content") }
  it { is_expected.to include("other essential content") }
end
```

### ❌ Don't Repeat File Reading

Avoid reading the same file multiple times in different tests:

```ruby
# DON'T DO THIS
it "includes class definition" do
  content = File.read(file_path)
  expect(content).to include("class SomeClass")
end

it "includes method definition" do  
  content = File.read(file_path)  # Reading same file again
  expect(content).to include("def some_method")
end
```

## Test Focus

### ✅ Test What Matters

Focus on essential functionality, not implementation details:

```ruby
# Test the important stuff
it { is_expected.to include("class Base < Superform::Rails::Form") }
it { is_expected.to include("def row(component)") }
```

### ❌ Don't Over-Test

Avoid brittle, line-by-line assertions:

```ruby
# DON'T DO THIS - too brittle
expect(lines[0]).to eq("module Components")
expect(lines[1]).to eq("  module Forms") 
expect(lines[2]).to eq("    class Base < Superform::Rails::Form")
```

## Test Structure

### ✅ Good Test Organization

- Use contexts to group related scenarios
- Use descriptive test names
- Keep tests focused and minimal
- Use `before` blocks to set up common state

### ✅ Integration Over Unit

- Test generators by actually running them
- Test the user experience, not internal methods
- Mock external dependencies, not internal logic

## Key Principles

1. **Integration over Unit**: Test how components work together, not in isolation
2. **User Experience**: Test what users actually do and see  
3. **Essential over Exhaustive**: Test what matters, not every edge case
4. **Readable over Clever**: Clear, simple tests are better than complex ones
5. **DRY but Clear**: Eliminate repetition without sacrificing readability

## Example: Good Generator Spec

See `spec/generators/superform/install_generator_spec.rb` for a complete example of these patterns in action.