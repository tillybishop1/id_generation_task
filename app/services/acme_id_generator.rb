# A couple of pharmacies are about to start taking blood samples for our pilot programme. We need to be able to track these from the moment they are taken until the lab processes them. Barcodes are used on the blood tubes to identify them and to allow the lab to upload the results.
# We need a tool to generate the IDs that conform to our specification. These IDs will then be printed out as barcodes at the individual pharmacies. The pilot start soon and we need an initial implementation of this tool that we can scale up later. Your solution should focus on just the ID generation tool.
# Key requirements:
# A user can specify how many IDs they want the tool to generate at run time. This is so IDs can be generated in batches and distributed to the pharmacies.
# IDs must be prefixed with the string "ACME" followed by a fixed number of digits and a final check digit. This scheme is similar to the one we use for the real thing, but we've made up the prefix here. Choose a size for the fixed number of digits that you think is appropriate. The check digit is used (later on) to detect an error when the ID is typed in incorrectly.
# For the check digit, use any algorithm from the check digit wikipedia page. Feel free to use a library to generate and validate check digits. We don't expect you to implement this yourself.
# IDs must be unique across all runs of the tool. It's crucial IDs used on the blood tubes are always unique and never clash with IDs already used, otherwise we could end up with bad data.

require 'securerandom'
require 'luhn'

class AcmeIdGenerator
  PREFIX = "ACME"
  DIGIT_COUNT = 8 # Allows for 100 million unique IDs
  MAX_BATCH_SIZE = 10_000

  def initialize(store: IdStore.new)
    @store = store
  end

  def generate_batch(count)
    raise ArgumentError, "Count must be a positive number" unless count.is_a?(Integer) && count > 0
    raise ArgumentError, "Count exceeds maximum batch size of #{MAX_BATCH_SIZE}" if count > MAX_BATCH_SIZE

    ids = []
    attempts = 0
  
    while ids.size < count
      id = generate_id
    
      begin
        @store.save(id)
        ids << id
      rescue ActiveRecord::RecordNotUnique => e
        attempts += 1
        next
      rescue => e
        Logger.error "Failed to save ID #{id}: #{e.message}"
        attempts += 1
        next
      end
    
      attempts += 1
      raise "Attempts failing to create IDs" if attempts > count * 3
    end
  
    ids
  end

  def generate_id
    digits = SecureRandom.random_number(DIGIT_COUNT).to_s.rjust(DIGIT_COUNT, "0")
    check = Luhn.checksum(digits.to_s).to_s
    "#{PREFIX}#{digits}#{check}"
  end

end
