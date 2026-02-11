# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shared::DeleteButtonComponent, type: :component do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  describe "basic delete button" do
    it "renders a primary delete button" do
      component = render_inline(described_class.new)

      expect(component.css(".btn.primary-delete-button")).to be_present
      expect(component.text).to include("Delete")
    end

    it "renders with custom text" do
      component = render_inline(described_class.new(text: "Remove"))

      expect(component.text).to include("Remove")
    end

    it "renders with icon" do
      component = render_inline(described_class.new(icon: "deleteProject"))

      expect(component.css("img[alt='Remove']")).to be_present
    end
  end

  describe "button variants" do
    it "renders primary variant" do
      component = render_inline(described_class.new(variant: :primary))

      expect(component.css(".primary-delete-button")).to be_present
    end

    it "renders secondary variant" do
      component = render_inline(described_class.new(variant: :secondary))

      expect(component.css(".secondary-button")).to be_present
    end
  end

  describe "button sizes" do
    it "renders small size" do
      component = render_inline(described_class.new(size: :small))

      expect(component.css(".btn-sm")).to be_present
    end

    it "renders large size" do
      component = render_inline(described_class.new(size: :large))

      expect(component.css(".btn-lg")).to be_present
    end
  end

  describe "link functionality" do
    it "renders as link when href is provided" do
      component = render_inline(described_class.new(
        href: "/projects/#{project.id}",
        method: :delete
      ))

      expect(component.css("a[href='/projects/#{project.id}']")).to be_present
    end

    it "includes confirmation message" do
      component = render_inline(described_class.new(
        href: "/projects/#{project.id}",
        confirm: "Are you sure?"
      ))

      expect(component.css("a[data-confirm='Are you sure?']")).to be_present
    end
  end

  describe "modal functionality" do
    it "includes modal data attributes" do
      component = render_inline(described_class.new(
        modal_target: "#deleteModal",
        data: { project_id: project.id }
      ))

      expect(component.css("[data-bs-toggle='modal']")).to be_present
      expect(component.css("[data-bs-target='#deleteModal']")).to be_present
      expect(component.css("[data-project-id='#{project.id}']")).to be_present
    end
  end

  describe "custom classes and data" do
    it "includes custom CSS classes" do
      component = render_inline(described_class.new(
        classes: ["custom-class", "another-class"]
      ))

      expect(component.css(".custom-class")).to be_present
      expect(component.css(".another-class")).to be_present
    end

    it "includes custom data attributes" do
      component = render_inline(described_class.new(
        data: { custom_attribute: "value" }
      ))

      expect(component.css("[data-custom-attribute='value']")).to be_present
    end
  end

  describe "disabled state" do
    it "renders disabled button when disabled" do
      component = render_inline(described_class.new(disabled: true))

      expect(component.css("button[disabled]")).to be_present
    end
  end
end
