# frozen_string_literal: true

class FooterLinksComponent < ViewComponent::Base
  def initialize(current_user)
    super()
    @current_user = current_user.is_a?(Hash) ? current_user[:current_user] : current_user
  end

  def left_column_links
    [
      { url: "/simulator", text: "layout.link_to_simulator" },
      { url: "/learn", text: "layout.link_to_learn_more", target: "_blank" },
      { url: "https://blog.circuitverse.org", text: "layout.link_to_blog", target: "_blank" },
      (if Flipper.enabled?(:circuit_explore_page, @current_user)
         { url: "/explore", text: "layout.footer.link_to_explore" }
       else
         { url: "/examples", text: "layout.footer.link_to_examples" }
       end),
      user_specific_link
    ]
  end

  def right_column_links
    [
      { url: "/docs", text: "layout.link_to_docs", target: "_blank" },
      { url: "/contribute", text: "layout.footer.link_to_contribute" },
      { url: "/teachers", text: "layout.link_to_teachers" },
      { url: "/about", text: "layout.link_to_about" },
      { url: "https://api.circuitverse.org", text: "API", target: "_blank" },
      { url: "https://docs.circuitverse.org/chapter8/chapter8-cvfaq", text: "layout.link_to_faq" }
    ]
  end

  def forum_enabled?
    Flipper.enabled?(:forum)
  end

  private

    def user_specific_link
      if @current_user
        { url: "/users/#{@current_user.id}", text: "layout.footer.my_circuits" }
      else
        { url: "/users/sign_in", text: "login" }
      end
    end
end
