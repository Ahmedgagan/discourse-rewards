# frozen_string_literal: true

class CampaignSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :description,
             :include_parameters,
             :start_date,
             :end_date,
             :created_at,
             :updated_at,
             :created_by

  def created_by
    object.created_by
  end
end
