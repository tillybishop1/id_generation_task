# Example usage of the ACME ID Generator

# In your controller or service or background job, with or without batch:
# user = current_user
# batch = IdBatch.create!(user: "Hello", pharmacy_name: "Pharmacy A")
# store = IdStore.new(batch: batch)
# generator = AcmeIdGenerator.new(store: store)
# ids = generator.generate_batch(10)


# Could then be exported to CSV, PDF, Excel, or barcode labels using a AcmeIdExportService