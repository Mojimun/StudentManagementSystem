class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :student, null: false, foreign_key: true
      t.string :street
      t.string :city
      t.string :state
      t.string :pin

      t.timestamps
    end
  end
end
