class BloodSampleId < ApplicationRecord
  belongs_to :id_batch
  
  validates :acme_id, presence: true, uniqueness: true
end
