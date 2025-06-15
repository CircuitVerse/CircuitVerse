# frozen_string_literal: true

class DonationCardComponentPreview < ViewComponent::Preview
    def default
      render ContributePageComponents::DonationCardComponent.new(
        image_path: "logos/opencollective-logo.png",
        link: "https://opencollective.com/CircuitVerse/contribute",
        alt_text: "Open Collective Logo",
        description: "Donate through Open Collective"
      )
    end
  end
  