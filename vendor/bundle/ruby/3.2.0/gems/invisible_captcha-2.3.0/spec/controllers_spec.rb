# frozen_string_literal: true

RSpec.describe InvisibleCaptcha::ControllerExt, type: :controller do
  render_views

  before(:each) do
    @controller = TopicsController.new
    request.env['HTTP_REFERER'] = 'http://test.host/topics'

    InvisibleCaptcha.init!
    InvisibleCaptcha.timestamp_threshold = 1
    InvisibleCaptcha.spinner_enabled = false
  end

  context 'without invisible_captcha_timestamp in session' do
    it 'fails like if it was submitted too fast' do
      post :create, params: { topic: { title: 'foo' } }

      expect(response).to redirect_to 'http://test.host/topics'
      expect(flash[:error]).to eq(InvisibleCaptcha.timestamp_error_message)
    end

    it 'passes if disabled at action level' do
      post :copy, params: { topic: { title: 'foo' } }

      expect(flash[:error]).not_to be_present
      expect(response.body).to be_present
    end

    it 'passes if disabled at app level' do
      InvisibleCaptcha.timestamp_enabled = false

      post :create, params: { topic: { title: 'foo' } }

      expect(flash[:error]).not_to be_present
      expect(response.body).to be_present
    end
  end

  context 'submission timestamp_threshold' do
    before(:each) do
      session[:invisible_captcha_timestamp] = Time.zone.now.iso8601
    end

    it 'fails if submission before timestamp_threshold' do
      post :create, params: { topic: { title: 'foo' } }

      expect(response).to redirect_to 'http://test.host/topics'
      expect(flash[:error]).to eq(InvisibleCaptcha.timestamp_error_message)

      # Make sure session is cleared
      expect(session[:invisible_captcha_timestamp]).to be_nil
    end

    it 'allows a custom on_timestamp_spam callback' do
      put :update, params: { id: 1, topic: { title: 'bar' } }

      expect(response.status).to eq(204)
    end

    it 'allows a new timestamp to be set in the on_timestamp_spam callback' do
      @controller.singleton_class.class_eval do
        def custom_timestamp_callback
          session[:invisible_captcha_timestamp] = 2.seconds.from_now(Time.zone.now).iso8601
          head(204)
        end
      end

      expect { put :update, params: { id: 1, topic: { title: 'bar' } } }
        .to change { session[:invisible_captcha_timestamp] }
        .to be_present
    end

    it 'runs on_spam callback if on_timestamp_spam callback is defined but passes' do
      put :test_passthrough, params: { id: 1, topic: { title: 'bar', subtitle: 'foo' } }

      expect(response.status).to eq(204)
    end

    context 'successful submissions' do
      it 'passes if submission on or after timestamp_threshold' do
        sleep InvisibleCaptcha.timestamp_threshold

        post :create, params: {
          topic: {
            title: 'foobar',
            author: 'author',
            body: 'body that passes validation'
          }
        }

        expect(flash[:error]).not_to be_present
        expect(response.body).to redirect_to(new_topic_path)

        # Make sure session is cleared
        expect(session[:invisible_captcha_timestamp]).to be_nil
      end

      it 'allow to set a custom timestamp_threshold per action' do
        sleep 2 # custom threshold

        post :publish, params: { id: 1 }

        expect(flash[:error]).not_to be_present
        expect(response.body).to redirect_to(new_topic_path)
      end

      it 'passes if on_timestamp_spam doesn\'t perform' do
        put :test_passthrough, params: { id: 1, topic: { title: 'bar' } }

        expect(response.body).to redirect_to(new_topic_path)
      end
    end
  end

  context 'honeypot attribute' do
    before(:each) do
      session[:invisible_captcha_timestamp] = Time.zone.now.iso8601

      # Wait for valid submission
      sleep InvisibleCaptcha.timestamp_threshold
    end

    it 'fails with spam' do
      post :create,  params: { topic: { subtitle: 'foo' } }

      expect(response.body).to be_blank
    end

    it 'passes with no spam' do
      post :create,  params: { topic: { title: 'foo' } }

      expect(response.body).to be_present
    end

    context 'with random honeypot' do
      context 'auto-scoped' do
        it 'passes with no spam' do
          post :categorize, params: { topic: { title: 'foo' } }

          expect(response.body).to redirect_to(new_topic_path)
        end

        it 'fails with spam' do
          post :categorize, params: { topic: { "#{InvisibleCaptcha.honeypots.sample}": 'foo' } }

          expect(response.body).not_to redirect_to(new_topic_path)
        end
      end

      context 'with no scope' do
        it 'passes with no spam' do
          post :categorize

          expect(response.body).to redirect_to(new_topic_path)
        end

        it 'fails with spam' do
          post :categorize, params: { "#{InvisibleCaptcha.honeypots.sample}": 'foo' }

          expect(response.body).not_to redirect_to(new_topic_path)
        end
      end

      context 'with scope' do
        it 'fails with spam' do
          post :rename, params: { topic: { "#{InvisibleCaptcha.honeypots.sample}": 'foo' } }

          expect(response.body).to be_blank
        end

        it 'passes with no spam' do
          post :rename, params: { topic: { title: 'foo' } }

          expect(response.body).to be_blank
        end
      end
    end

    it 'allow a custom on_spam callback' do
      put :update,  params: { id: 1, topic: { subtitle: 'foo' } }

      expect(response.body).to redirect_to(new_topic_path)
    end

    it 'honeypot is removed from params if you use a custom honeypot' do
      post :create,  params: { topic: { title: 'foo', subtitle: '' } }

      expect(flash[:error]).not_to be_present
      expect(@controller.params[:topic].key?(:subtitle)).to eq(false)
    end

    describe 'ActiveSupport::Notifications' do
      let(:dummy_handler) { double(handle_event: nil) }

      let!(:subscriber) do
        subscriber = ActiveSupport::Notifications.subscribe('invisible_captcha.spam_detected') do |*args, data|
          dummy_handler.handle_event(data)
        end

        subscriber
      end

      after { ActiveSupport::Notifications.unsubscribe(subscriber) }

      it 'dispatches an `invisible_captcha.spam_detected` event' do
        expect(dummy_handler).to receive(:handle_event).once.with({
          message: "[Invisible Captcha] Potential spam detected for IP 0.0.0.0. Honeypot param 'subtitle' was present.",
          remote_ip: '0.0.0.0',
          user_agent: 'Rails Testing',
          controller: 'topics',
          action: 'create',
          url: 'http://test.host/topics',
          params: {
            topic: { subtitle: "foo"},
            controller: 'topics',
            action: 'create'
          }
        })

        post :create, params: { topic: { subtitle: 'foo' } }
      end
    end
  end

  context 'spinner attribute' do
    before(:each) do
      InvisibleCaptcha.spinner_enabled = true
      InvisibleCaptcha.secret = 'secret'
      session[:invisible_captcha_timestamp] = Time.zone.now.iso8601
      session[:invisible_captcha_spinner] = '32ab649161f9f6faeeb323746de1a25d'

      # Wait for valid submission
      sleep InvisibleCaptcha.timestamp_threshold
    end

    it 'fails with no spam, but mismatch of spinner' do
      post :create,  params: { topic: { title: 'foo' }, spinner: 'mismatch' }

      expect(response.body).to be_blank
    end

    it 'passes with no spam and spinner match' do
      post :create,  params: { topic: { title: 'foo' }, spinner: '32ab649161f9f6faeeb323746de1a25d' }

      expect(response.body).to be_present
    end
  end
end
