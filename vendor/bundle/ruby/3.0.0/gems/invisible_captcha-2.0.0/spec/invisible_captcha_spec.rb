# frozen_string_literal: true

RSpec.describe InvisibleCaptcha do
  it 'initialize with defaults' do
    InvisibleCaptcha.init!

    expect(InvisibleCaptcha.sentence_for_humans).to eq('If you are a human, ignore this field')
    expect(InvisibleCaptcha.timestamp_threshold).to eq(4.seconds)
    expect(InvisibleCaptcha.timestamp_error_message).to eq('Sorry, that was too quick! Please resubmit.')
    expect(InvisibleCaptcha.honeypots).to be_an_instance_of(Array)
    expect(InvisibleCaptcha.injectable_styles).to eq(false)
  end

  it 'allow setup via block' do
    InvisibleCaptcha.setup do |ic|
      ic.sentence_for_humans = 'Another sentence'
    end

    expect(InvisibleCaptcha.sentence_for_humans).to eq('Another sentence')
  end

  it 'It uses I18n when available' do
    InvisibleCaptcha.init!

    I18n.available_locales = [:en, :fr]

    I18n.backend.store_translations(:en,
                                    'invisible_captcha' => {
                                       'sentence_for_humans' => "Can't touch this",
                                       'timestamp_error_message' => 'Fast and furious' })

    I18n.backend.store_translations(:fr,
                                    'invisible_captcha' => {
                                       'sentence_for_humans' => 'Ne touchez pas',
                                       'timestamp_error_message' => 'Plus doucement SVP' })

    I18n.locale = :en
    expect(InvisibleCaptcha.sentence_for_humans).to eq("Can't touch this")
    expect(InvisibleCaptcha.timestamp_error_message).to eq('Fast and furious')

    I18n.locale = :fr
    expect(InvisibleCaptcha.sentence_for_humans).to eq('Ne touchez pas')
    expect(InvisibleCaptcha.timestamp_error_message).to eq('Plus doucement SVP')

    I18n.backend.reload!
    expect(InvisibleCaptcha.sentence_for_humans).to eq('If you are a human, ignore this field')
    expect(InvisibleCaptcha.timestamp_error_message).to eq('Sorry, that was too quick! Please resubmit.')
  end
end
