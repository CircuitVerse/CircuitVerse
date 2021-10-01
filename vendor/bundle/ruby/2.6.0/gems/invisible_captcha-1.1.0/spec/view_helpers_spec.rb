# frozen_string_literal: true

RSpec.describe InvisibleCaptcha::ViewHelpers, type: :helper do
  before(:each) do
    allow(Time.zone).to receive(:now).and_return(Time.zone.parse('Feb 19 1986'))
    allow(InvisibleCaptcha).to receive(:css_strategy).and_return("display:none;")

    if Rails.version >= '5.2'
      allow_any_instance_of(ActionDispatch::ContentSecurityPolicy::Request).to receive(:content_security_policy_nonce).and_return('123')
    end

    # to test content_for and provide
    @view_flow = ActionView::OutputFlow.new

    InvisibleCaptcha.init!
  end

  it 'with no arguments' do
    InvisibleCaptcha.honeypots = [:foo_id]
    expect(invisible_captcha).to match(/name="foo_id"/)
  end

  it 'with specific honeypot' do
    expect(invisible_captcha(:subtitle)).to match(/name="subtitle"/)
  end

  it 'with specific honeypot and scope' do
    expect(invisible_captcha(:subtitle, :topic)).to match(/name="topic\[subtitle\]"/)
  end

  it 'with custom html options' do
    expect(invisible_captcha(:subtitle, :topic, { class: 'foo_class' })).to match(/class="foo_class"/)
  end

  if Rails.version >= '5.2'
    it 'with CSP nonce' do
      expect(invisible_captcha(:subtitle, :topic, { nonce: true })).to match(/nonce="123"/)
    end
  end

  it 'generated html + styles' do
    InvisibleCaptcha.honeypots = [:foo_id]
    output = invisible_captcha.gsub("\"", "'")
    regexp = %r{<div class='foo_id_\w*'><style.*>.foo_id_\w* {display:none;}</style><label.*>#{InvisibleCaptcha.sentence_for_humans}</label><input (?=.*name='foo_id'.*)(?=.*autocomplete='off'.*)(?=.*tabindex='-1'.*).*/></div>}

    expect(output).to match(regexp)
  end

  context "honeypot visibilty" do
    it 'visible from defaults' do
      InvisibleCaptcha.visual_honeypots = true

      expect(invisible_captcha).not_to match(/display:none/)
    end

    it 'visible from given instance (default override)' do
      expect(invisible_captcha(visual_honeypots: true)).not_to match(/display:none/)
    end

    it 'invisible from given instance (default override)' do
      InvisibleCaptcha.visual_honeypots = true

      expect(invisible_captcha(visual_honeypots: false)).to match(/display:none/)
    end
  end

  it 'should set spam timestamp' do
    invisible_captcha
    expect(session[:invisible_captcha_timestamp]).to eq(Time.zone.now.iso8601)
  end

  context 'injectable_styles option' do
    it 'by default, render styles along with the honeypot' do
      expect(invisible_captcha).to match(/display:none/)
      expect(@view_flow.content[:invisible_captcha_styles]).to be_blank
    end

    it 'if injectable_styles is set, do not append styles inline' do
      InvisibleCaptcha.injectable_styles = true

      expect(invisible_captcha).not_to match(/display:none;/)
      expect(@view_flow.content[:invisible_captcha_styles]).to match(/display:none;/)
    end
  end
end
