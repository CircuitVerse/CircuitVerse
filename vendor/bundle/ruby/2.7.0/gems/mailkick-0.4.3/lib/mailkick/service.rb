module Mailkick
  class Service
    def fetch_opt_outs
      opt_outs.each do |api_data|
        email = api_data[:email]
        time = api_data[:time]

        opt_out = Mailkick::OptOut.where(email: email).order("updated_at desc").first
        if !opt_out || (time > opt_out.updated_at && !opt_out.active)
          Mailkick.opt_out(
            email: email,
            user: Mailkick.user_method ? Mailkick.user_method.call(email) : nil,
            reason: api_data[:reason],
            time: time
          )
        end
      end

      true
    end
  end
end
