# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AcmeIdGenerator do
  let(:store) { IdStore.new }
  let(:generator) { AcmeIdGenerator.new(store: store) }

  describe '#generate_id' do
    subject { generator.generate_id }

    it 'returns a string' do
      expect(subject).to be_a(String)
    end

    it 'starts with the correct prefix' do
      expect(subject).to start_with('ACME')
    end

    it 'has the correct total length' do
      length = PREFIX.length + DIGIT_COUNT.count + 1
      expect(subject.length).to eq(length)
    end

    it 'contains only alphanumeric characters after prefix' do
      digits_part = subject[4..-1]
      expect(digits_part).to match(/\A\d+\z/)
    end

    it 'generates different IDs on subsequent calls' do
      id1 = generator.generate_id
      id2 = generator.generate_id
      expect(id1).not_to eq(id2)
    end

    it 'generates valid Luhn check digit' do
      id = subject
      digits = id[4, 8] # Extract the 8 digits after ACME
      check_digit = id[-1].to_i
      expected_check = Luhn.checksum(digits)
      
      expect(check_digit).to eq(expected_check)
    end
  end

  describe '#generate_batch' do
    let(:count) { 5 }

    before do
      allow(store).to receive(:exists?).and_return(false)
      allow(store).to receive(:save)
    end

    context 'with valid parameters' do
      it 'returns an array of IDs' do
        result = generator.generate_batch(count)
        expect(result).to be_an(Array)
        expect(result.length).to eq(count)
      end

      it 'returns unique IDs' do
        result = generator.generate_batch(count)
        expect(result.uniq.length).to eq(result.length)
      end

      it 'calls store.exists? for each generated ID' do
        expect(store).to receive(:exists?).exactly(count).times
        generator.generate_batch(count)
      end

      it 'calls store.save for each new ID' do
        expect(store).to receive(:save).exactly(count).times
        generator.generate_batch(count)
      end
    end

    context 'when IDs already exist in store' do
      before do
        call_count = 0
        allow(store).to receive(:exists?) do
          call_count += 1
          call_count <= 2
        end
      end

      it 'skips existing IDs and generates new ones' do
        expect(store).to receive(:save).exactly(count).times
        result = generator.generate_batch(count)
        expect(result.length).to eq(count)
      end
    end

    context 'when store.save fails' do
      before do
        allow(store).to receive(:exists?).and_return(false)
        allow(store).to receive(:save).and_raise(StandardError, "Database error")
        allow(Logger).to receive(:error)
      end

      it 'logs error and continues trying' do
        expect(Logger).to receive(:error).at_least(:once)
        expect { generator.generate_batch(1) }.to raise_error("Attempts failing to create IDs")
      end

      it 'raises error when attempts exceed limit' do
        expect { generator.generate_batch(1) }.to raise_error("Attempts failing to create IDs")
      end
    end

    context 'edge cases' do
      it 'works with batch size of 1' do
        result = generator.generate_batch(1)
        expect(result.length).to eq(1)
      end

      it 'works with maximum allowed batch size' do
        expect(store).to receive(:exists?).exactly(described_class::MAX_BATCH_SIZE).times.and_return(false)
        expect(store).to receive(:save).exactly(described_class::MAX_BATCH_SIZE).times
        
        result = generator.generate_batch(described_class::MAX_BATCH_SIZE)
        expect(result.length).to eq(described_class::MAX_BATCH_SIZE)
      end
    end
  end

  describe 'ID format validation' do
    
    it 'generates IDs that match expected format' do
      id = generator.generate_id
      expect(id).to match(/\AACME\d{8}\d\z/)
    end

    it 'generates IDs with valid check digits' do
      id = generator.generate_id
      digits = id[4, 8]
      check_digit = id[-1].to_i
      expected_check = Luhn.checksum(digits)
      
      expect(check_digit).to eq(expected_check)
    end
  end
end
