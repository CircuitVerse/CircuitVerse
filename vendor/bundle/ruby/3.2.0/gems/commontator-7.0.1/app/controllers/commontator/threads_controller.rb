class Commontator::ThreadsController < Commontator::ApplicationController
  skip_before_action :ensure_user, only: :show
  before_action :set_thread
  before_action :commontator_set_thread_variables, except: :mentions
  before_action :commontator_set_new_comment, only: [ :show, :reopen ]

  # GET /threads/1
  def show
    respond_to do |format|
      format.html { redirect_to commontable_url }
      format.js   { commontator_thread_show(@commontator_thread.commontable) }
    end
  end

  # PUT /threads/1/close
  def close
    security_transgression_unless @commontator_thread.can_be_edited_by?(@commontator_user)

    @commontator_thread.errors.add(:base, t('commontator.thread.errors.already_closed')) \
      unless @commontator_thread.close(@commontator_user)

    respond_to do |format|
      format.html { redirect_to commontable_url }
      format.js   do
        commontator_thread_show(@commontator_thread.commontable)
        render :show
      end
    end
  end

  # PUT /threads/1/reopen
  def reopen
    security_transgression_unless @commontator_thread.can_be_edited_by?(@commontator_user)

    @commontator_thread.errors.add(:base, t('commontator.thread.errors.not_closed')) \
      unless @commontator_thread.reopen

    respond_to do |format|
      format.html { redirect_to commontable_url }
      format.js   do
        commontator_thread_show(@commontator_thread.commontable)
        render :show
      end
    end
  end

  # GET /threads/1/mentions.json
  def mentions
    security_transgression_unless @commontator_thread.can_be_read_by?(@commontator_user) &&
                                  @commontator_thread.config.mentions_enabled

    respond_to do |format|
      format.json do
        query = params[:q].to_s

        if query.size < 3
          render json: { errors: ['Query string is too short (minimum 3 characters)'] },
                 status: :unprocessable_entity
        else
          render json: {
            mentions: Commontator.commontator_mentions(
              @commontator_user, @commontator_thread, query
            ).map { |user| { id: user.id, name: Commontator.commontator_name(user), type: 'user' } }
          }
        end
      end
    end
  end
end
