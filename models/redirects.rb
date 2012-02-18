class Redirects < ActiveRecord::Base
  validates_uniqueness_of :subdomain
  before_save :validate_downcase_on_subdomain
  
  private
  
  def validate_downcase_on_subdomain
    self.subdomain = self.subdomain.downcase
  end
end
