require 'rails_i18n/pluralization'

{ :gd => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :two, :few, :other],
        :rule => RailsI18n::Pluralization::ScottishGaelic.rule }}}}
