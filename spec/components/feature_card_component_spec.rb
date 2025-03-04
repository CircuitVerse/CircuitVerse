require "rails_helper"

RSpec.describe FeatureCardComponent, type: :component do
  let(:image) { "homepage/export-hd.png" }  

  it "renders the feature card with correct content" do
    image_path = ActionController::Base.helpers.asset_path(image) 

    render_inline(FeatureCardComponent.new(
      image: image_path,  
      alt: "Test Alt", 
      title: "Test Title", 
      text: "Test Text"
    ))

    expect(page).to have_css("img[src*='export-hd']")
    expect(page).to have_text("Test Title")
    expect(page).to have_text("Test Text")
  end
end  

