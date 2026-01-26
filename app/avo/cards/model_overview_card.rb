# frozen_string_literal: true

class Avo::Cards::ModelOverviewCard < Avo::Cards::MetricCard
  self.id = "model_overview_card"
  self.label = "Model Overview"
  self.cols = 1
  self.display_header = true

  def initialize(model:, label:, resource_path:, **args)
    @model = model
    @label = label
    @resource_path = resource_path
    super(**args)
  end
  # rubocop:disable Metrics/MethodLength

  def query
    count = @model.count

    # Get the last created record
    last_record = begin
      @model.order(created_at: :desc).first
    rescue StandardError
      nil
    end

    # Format the time ago text
    last_created_text = if last_record
      time_ago_text(last_record.created_at)
    else
      "Never"
    end

    result(
      value: count,
      label: @label,
      description: "Last created: #{last_created_text}",
      prefix: "",
      suffix: "",
      format: "0,0"
    ).label(@label)
      .link_to(@resource_path)
  end
  # rubocop:enable Metrics/MethodLength

  private

    # rubocop:disable Metrics/MethodLength

    def time_ago_text(time)
      distance = Time.current - time

      case distance
      when 0...60
        "#{distance.to_i} seconds ago"
      when 60...3600
        minutes = (distance / 60).floor
        "#{minutes} #{minutes == 1 ? 'minute' : 'minutes'} ago"
      when 3600...86_400
        hours = (distance / 3600).floor
        "#{hours} #{hours == 1 ? 'hour' : 'hours'} ago"
      when 86_400...2_592_000
        days = (distance / 86_400).floor
        "#{days} #{days == 1 ? 'day' : 'days'} ago"
      when 2_592_000...31_536_000
        months = (distance / 2_592_000).floor
        "#{months} #{months == 1 ? 'month' : 'months'} ago"
      else
        years = (distance / 31_536_000).floor
        "#{years} #{years == 1 ? 'year' : 'years'} ago"
      end
    end
  # rubocop:enable Metrics/MethodLength
end
