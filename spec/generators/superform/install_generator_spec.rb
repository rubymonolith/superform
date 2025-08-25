# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "generators/superform/install/install_generator"
require "tmpdir"
require "fileutils"

RSpec.describe Superform::InstallGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([], {}, { destination_root: destination_root }) }

  before do
    FileUtils.mkdir_p(destination_root)
    allow(Rails).to receive(:root).and_return(Pathname.new(destination_root))
  end

  after do
    FileUtils.rm_rf(destination_root) if File.exist?(destination_root)
  end

  context "when phlex-rails is not installed" do
    before do
      allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(false)
      allow(generator).to receive(:say)
      allow(generator).to receive(:exit).and_raise(SystemExit)
    end

    it "fails with helpful error message" do
      expect { generator.invoke_all }.to raise_error(SystemExit)
    end
  end

  context "when phlex-rails is installed" do
    before do
      allow(generator).to receive(:gem_in_bundle?).with("phlex-rails").and_return(true)
    end

    it "creates the base form component" do
      generator.invoke_all

      expect(File.exist?(File.join(destination_root, "app/components/forms/base.rb"))).to be true
    end

    describe "generated file" do
      subject { File.read(File.join(destination_root, "app/components/forms/base.rb")) }

      before { generator.invoke_all }

      it { is_expected.to include("module Components") }
      it { is_expected.to include("class Base < Superform::Rails::Form") }
      it { is_expected.to include("def row(component)") }
      it { is_expected.to include("def error_messages") }
    end
  end
end