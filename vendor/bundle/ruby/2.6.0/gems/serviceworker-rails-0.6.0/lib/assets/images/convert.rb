# frozen_string_literal: true

# rubocop:disable Lint/Void
%w[48 60 72 76 96 120 152 180 192 512].each do |dim|
  %(convert heart-1200x1200.png -resize #{dim}x heart-#{dim}x#{dim}.png)
end
# rubocop:enable Lint/Void
