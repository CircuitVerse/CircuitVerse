%w(abstract_search standard_search more_like_this_search query_facet
   field_facet field_json_facet date_facet range_facet json_facet_stats
   facet_row json_facet_row hit highlight field_group group hit_enumerable
   stats_row stats_json_row field_stats stats_facet query_group).each do |file|
  require File.join(File.dirname(__FILE__), 'search', file)
end

module Sunspot
  module Search
  end
end
