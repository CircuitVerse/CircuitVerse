# frozen_string_literal: true

class NoticedNotification < ApplicationRecord
  # Noticed picks the coder for `params` by asking the database for the column
  # type while this class loads. If Postgres is unreachable at that moment (for
  # example while it is still starting during a deploy), Noticed silently falls
  # back to Noticed::TextCoder, which calls JSON.parse on the Hash our jsonb
  # column already returns. Every notification then fails to render in that
  # process until it restarts (#7685). `params` is always jsonb, so skip the
  # lookup. This must be defined before `include Noticed::Model`, which calls it.
  def self.noticed_coder
    Noticed::Coder
  end

  include Noticed::Model

  belongs_to :recipient, polymorphic: true
end
