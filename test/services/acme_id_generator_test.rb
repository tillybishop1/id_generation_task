# frozen_string_literal: true

require 'test_helper'

class AcmeIdGeneratorTest < ActiveSupport::TestCase
  def setup
    @store = Minitest::Mock.new
    @logger = Minitest::Mock.new
    @generator = AcmeIdGenerator.new(store: @store, logger: @logger)
  end

  test "generates valid ID format" do
    @store.expect(:save, true, [String])
    @logger.expect(:info, nil, [String])
    @logger.expect(:debug, nil, [String])
    @logger.expect(:info, nil, [String])

    ids = @generator.generate_batch(1)
    
    assert_equal 1, ids.length
    assert_match(/\AACME\d{8}\d\z/, ids.first)
    assert AcmeIdGenerator.valid_id?(ids.first)
  end

  test "validates batch count" do
    assert_raises(AcmeIdGenerator::InvalidBatchSizeError) do
      @generator.generate_batch(0)
    end

    assert_raises(AcmeIdGenerator::InvalidBatchSizeError) do
      @generator.generate_batch(-1)
    end

    assert_raises(AcmeIdGenerator::InvalidBatchSizeError) do
      @generator.generate_batch("invalid")
    end
  end

  test "enforces maximum batch size" do
    assert_raises(AcmeIdGenerator::InvalidBatchSizeError) do
      @generator.generate_batch(AcmeIdGenerator::MAX_BATCH_SIZE + 1)
    end
  end

  test "valid_id? validates correct format and check digit" do
    # Valid ID with correct check digit
    assert AcmeIdGenerator.valid_id?("ACME123456782")
    
    # Invalid format
    refute AcmeIdGenerator.valid_id?("INVALID123456782")
    refute AcmeIdGenerator.valid_id?("ACME12345678") # too short
    refute AcmeIdGenerator.valid_id?("ACME1234567890") # too long
    
    # Invalid check digit
    refute AcmeIdGenerator.valid_id?("ACME123456789")
  end
end
