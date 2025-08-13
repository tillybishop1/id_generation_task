# frozen_string_literal: true

# Storage backend for ACME ID persistence
#
# Handles database operations for blood sample ID storage with proper
# error handling and thread-safety considerations.
class IdStore
  # @param batch [IdBatch, nil] Optional batch to associate IDs with
  def initialize(batch: nil)
    @batch = batch
  end

  # Checks if an ID already exists in the database
  #
  # @param id [String] The ACME ID to check
  # @return [Boolean] True if ID exists, false otherwise
  def exists?(id)
    BloodSampleId.exists?(acme_id: id)
  end

  # Saves an ID to the database with proper error handling
  #
  # @param id [String] The ACME ID to save
  # @return [BloodSampleId] The created record
  # @raise [ActiveRecord::RecordNotUnique] If ID already exists
  # @raise [ActiveRecord::RecordInvalid] If validation fails
  def save(id)
    BloodSampleId.create!(acme_id: id, id_batch: @batch)
  rescue ActiveRecord::RecordNotUnique => e
    # Re-raise with more context for better debugging
    raise ActiveRecord::RecordNotUnique, "ID '#{id}' already exists in database: #{e.message}"
  end
end
