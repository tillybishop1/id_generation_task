class CreateIdBatchesAndBloodSampleIds < ActiveRecord::Migration[7.1]
  def change
    create_table :id_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.string :pharmacy_name, null: false
      t.timestamps
    end

    create_table :blood_sample_ids do |t|
      t.string :acme_id, null: false
      t.references :id_batch, null: false, foreign_key: true
      t.timestamps
    end

    add_index :blood_sample_ids, :acme_id, unique: true
  end
end
