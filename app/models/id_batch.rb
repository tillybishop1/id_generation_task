class IdBatch < ApplicationRecord
  belongs_to :user
  has_many :blood_sample_ids, dependent: :destroy
  
  validates :pharmacy_name, presence: true
end
