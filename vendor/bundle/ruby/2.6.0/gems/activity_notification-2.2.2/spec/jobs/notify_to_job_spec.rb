describe ActivityNotification::NotifyToJob, type: :job do
  before do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    @author_user = create(:confirmed_user)
    @user        = create(:confirmed_user)
    @article     = create(:article, user: @author_user)
    @comment     = create(:comment, article: @article, user: @user)
  end

  describe "#perform_later" do
    it "generates notification" do
      expect {
        ActivityNotification::NotifyToJob.perform_later(@user, @comment)
      }.to have_enqueued_job
    end

    it "generates notification once" do
      ActivityNotification::NotifyToJob.perform_later(@user, @comment)
      expect(ActivityNotification::NotifyToJob).to have_been_enqueued.exactly(:once)
    end
  end
end
