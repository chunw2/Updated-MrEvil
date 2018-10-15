class Testing < ActiveRecord::Migration[5.2]
  def change
    
    create_table :users do |t|
      t.string :name
      t.string :number
      t.datetime :alarm
      t.timestamps
    end
      
  end
end
