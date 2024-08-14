# Delete Button View Component

This View Component replaces the delete button across CircuitVerse to ensure reusability, encapsulation, and ease of testing. The component integrates seamlessly with Ruby on Rails, allowing for consistent behavior across different views.

## Overview

The `DeleteButtonComponent` is a reusable View Component that renders a delete button for user profiles in CircuitVerse. It checks if the current user is present before rendering the button.

### Key Features

- **Reusability:** The component can be used in multiple views without duplicating code.
- **Encapsulation:** The logic for rendering the delete button is encapsulated within the component.
- **Testability:** The component is easily testable, ensuring that the delete button behaves correctly in different scenarios.

## Component Files

- **Ruby Class:** `app/component/delete_button_component.rb`
- **HTML Template:** `app/component/delete_button_component.html.erb`

### Ruby Class

The `DeleteButtonComponent` Ruby class initializes the component with the `current_user` and `profile_id`. It ensures that the delete button is only rendered when a user is logged in.

```ruby
class DeleteButtonComponent < ViewComponent::Base
  def initialize(current_user:, profile_id:)
    @current_user = current_user
    @profile_id = profile_id
  end

  def render?
    @current_user.present?
  end
end
```

**HTML Template**
The HTML template defines the structure of the delete button. It uses Rails' link_to helper to create a link styled as a button that triggers a modal for deleting the user.

`<%= link_to t("users.circuitverse.edit_profile.delete_account"), "#", class: "btn primary-delete-button", data: { toggle: "modal", target: "#deleteuserModal", currentuser: @profile_id } %>`

**Usage**
To integrate the DeleteButtonComponent in your views, simply replace the existing delete button code with the following:

`<%= render DeleteButtonComponent.new(current_user: current_user, profile_id: @profile.id) %>`
