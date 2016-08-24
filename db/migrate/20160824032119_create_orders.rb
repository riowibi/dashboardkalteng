class CreateOrders < ActiveRecord::Migration
  
	def up
	    create_table :orders do |t|
	    	t.string "sc"
	    	t.datetime "orderdate"
	      t.string "ncli"
	      t.string "customer"
	      t.string "address"
	      t.string "nd_internet"
	      t.string "nd_voice"
	      t.string "witel"
	      t.string "sto"
	      t.string "odp"
	      t.string "status"
	      t.string "status_message"
	      t.string "k_contact"
	      t.string "inputer"
	      t.string "transaction_type"
	      t.string "status_va"

	      t.datetime "created_at"
	      t.datetime "updated_at"
		  t.timestamps
		end
	end

	def down
	  drop_table :orders 
	end

end
