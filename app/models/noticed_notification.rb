# frozen_string_literal: true

class NoticedNotification < ApplicationRecord
  # Coder for the jsonb `params` column. Rows written by a process that had
  # fallen back to Noticed::TextCoder hold a JSON string instead of an object,
  # so parse those first to keep them readable.
  module ParamsCoder
    def self.load(data)
      data = JSON.parse(data) if data.is_a?(String)
      Noticed::Coder.load(data)
    end

    def self.dump(data)
      Noticed::Coder.dump(data)
    end
  end

  # Noticed picks the coder for `params` by asking the database for the column
  # type while this class loads. If Postgres is unreachable at that moment (for
  # example while it is still starting during a deploy), Noticed silently falls
  # back to Noticed::TextCoder, which calls JSON.parse on the Hash our jsonb
  # column already returns. Every notification then fails to render in that
  # process until it restarts (#7685). `params` is always jsonb, so skip the
  # lookup. This must be defined before `include Noticed::Model`, which calls it.
  def self.noticed_coder
    ParamsCoder
  end

  include Noticed::Model

  belongs_to :recipient, polymorphic: true
end
