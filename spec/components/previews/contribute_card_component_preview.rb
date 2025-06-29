# frozen_string_literal: true

class ContributeCardComponentPreview < ViewComponent::Preview
  def student_card
    render(
      Contribute::CardComponent.new(
        image_src: "SVGs/student.svg",
        alt_text: "Student Icon",
        title_key: "circuitverse.contribute.student_card.main_heading",
        items: [
          "circuitverse.contribute.student_card.item1_text",
          "circuitverse.contribute.student_card.item2_text_html",
          "circuitverse.contribute.student_card.item3_text"
        ]
      )
    )
  end
end
