class Task < ActiveRecord::Base

  belongs_to :hunt

  has_many :user_tasks
  has_many :users, through: :user_tasks

  before_save :remove_parens

  def remove_parens
    if self.geo.present?
      self.geo = self.geo.gsub('(', '').gsub(')', '')
    end
  end

  def default_hunt_option
    option = self.hunt_id ? self.hunt_id : Hunt.first.id
    option
  end

  def self.hunt_options
    hunts = []
    Hunt.find_each do |hunt|
      hunts << [hunt.name, hunt.id]
    end
    hunts
  end

  def self.claim_types
    ["plant code", "image match", "QR"]
  end

  def self.search_wikipedia(query)
    require 'openssl'
    require 'wikipedia'
    begin
      prev_setting = OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
      OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)

      wikipedia = Wikipedia.find(query)

      # do my connnection thang!
      # OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
      # OpenSSL::SSL.const_set(:VERIFY_PEER, prev_setting)

      if wikipedia.image_urls.present?
        image = wikipedia.image_urls.first
        excerpt = wikipedia.summary
        success = true
      else
        success = false
      end

    rescue
      success = false
      excerpt = ''
      image = ''
    end

     return {:success => success, :excerpt => excerpt, :image => image}
  end
end
