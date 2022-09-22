# frozen_string_literal: true

RSpec.describe InvisibleCaptcha::ViewHelpers, type: :helper do
  before(:each) do
    allow(InvisibleCaptcha).to receive(:css_strategy).and_return("display:none;")
    allow_any_instance_of(ActionDispatch::ContentSecurityPolicy::Request).to receive(:content_security_policy_nonce).and_return('123')

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

  it 'with CSP nonce' do
    expect(invisible_captcha(:subtitle, :topic, { nonce: true })).to match(/nonce="123"/)
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

  context "should have spinner field" do
    it 'that exists by default, spinner_enabled is true' do
      InvisibleCaptcha.spinner_enabled = true
      expect(invisible_captcha).to match(/spinner/)
    end

    it 'that does not exist if spinner_enabled is false' do
      InvisibleCaptcha.spinner_enabled = false
      expect(invisible_captcha).not_to match(/spinner/)
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
