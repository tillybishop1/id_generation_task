class IdStore
  def initialize(batch: nil)
    @batch = batch
  end

  def exists?(id)
    BloodSampleId.exists?(acme_id: id)
  end

  def save(id)
    BloodSampleId.create!(acme_id: id, id_batch: @batch)
  rescue ActiveRecord::RecordNotUnique => e
    raise ActiveRecord::RecordNotUnique, "ID '#{id}' already exists in database: #{e.message}"
  end
end
