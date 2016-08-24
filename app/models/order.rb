class Order < ActiveRecord::Base

	require 'csv'
	require 'roo'
	require 'open-uri'
	require 'json'
	require 'pp'

	:flash_notice

	# Manual Ways Export Excel

	def self.to_csv(options = {})
	  	CSV.generate(options) do |csv|
	    	csv << ["SC", "Tanggal Order", "NCLI", "Pelanggan", "Alamat", "NDInet", "NDVoice", "Witel", "STO", "ODP", "Status", "Status Message", "K-Kontak", "Inputer", "Tipe Transaksi", "VA"]
	    	all.each do |product|
	      		csv << product.attributes.values_at("sc", "orderdate", "ncli", "customer", "address", "nd_internet", "nd_voice", "witel", "sto", "odp", "status", "status_message", "k_contact", "inputer", "transaction_type", "status_va")
	    	end
	  	end
	end


	# Roo Ways Import Excel

	def import
	  Order.import(params[:file])
	  redirect_to root_url, notice: "decorations imported."
	end

	def self.import(file)
	  	spreadsheet = Roo::Spreadsheet.open(file.path)
	  	#header = spreadsheet.row(1)
	  	#(2..spreadsheet.last_row).each do |i|
	  	spreadsheet.each do |row|
	    	# rows = Hash[[header, spreadsheet.row(i)].transpose]
	    	# product = User.find_by(id: rows["id"]) || new
	    	# product.attributes = rows.to_hash
	    	product.sc = row[0]
			product.orderDate = row[1]
			product.ncli = row[4]
			product.customer = row[5]
			product.address = row[6]
			product.ndInternet = row[9]
			product.ndVoice = row[10]
			product.status = row[11]
			product.statusMessage = row[12]
			product.odp = row[13]
			product.witel = row[14]
			product.kContact = row[15]
			product.inputer = row[16]
			product.transactionType = row[17]
			product.serviceType = row[18]
			product.sto = row[19]

			# checkin SC function
			#	# if exist, Skip
			# checkin Status SC function
			#	# if it changes, Update! 

			if product.sc != "No. SC"
				if Order.find_by(sc: product.sc)
	    			#unless User.where(user: product.user, steps: product.steps)
	    			#id = User.where (user: product.user).select("id").first
	    			id = Order.where(sc: product.sc).select("id").first
	    			status = Order.where(sc: product.sc).select("status").first
	    			if status != product.status
	    				Order.update(id, status: product.status)
	    				Order.update(id, statusMessage: product.statusMessage)
	    			else
	    				next
	    			end
	    		else
	    			product.save
	    		end
	    	end

	  	end
	end

	def self.open_spreadsheet(file)
	  	case File.extname(file.original_filename)
	  	when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
	  	when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
	  	when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
	  	else raise "Unknown file type: #{file.original_filename}"
	  	end
	end

	def self.starclick

		request_uri = 'https://starclick.telkom.co.id/noss_prod/data/get_order.php?_dc=1471594704134&SearchText=kalteng&Field=ORG&Fieldstatus=&Fieldwitel=&StartDate=&EndDate=&page=1&start=0&limit=5'
      	request_query = ''
      	url = "#{request_uri}#{request_query}"

      	buffer = open(url).read

      	result = JSON.parse(buffer)

      	data = result["order"]

      	data.each do |row| 	
	      	product = Order.new

			product.sc = row["orderId"]
			product.orderDate = row["orderDate"]
			product.ncli = row["orderNcli"]
			product.customer = row["orderName"]
			product.address = row["orderAddr"]
			product.ndInternet = row["ndemSpeedy"]
			product.ndVoice = row["ndemPots"]
			product.status = row["orderStatus"]
			product.statusMessage = row["orderPaket"]
			product.odp = row["alproName"]
			product.witel = row["orderPlasa"]
			product.kContact = row["kcontact"]
			product.inputer = row["username"]
			product.transactionType = row["jenisPsb"]
			product.sto = row["sto"]

			if Order.find_by(sc: product.sc)
	    		id = Order.where(sc: product.sc).select("id").first
	    		status = Order.where(sc: product.sc).select("status").first
	    		if status != product.status
	    			Order.update(id, status: product.status)
	    			Order.update(id, statusMessage: product.statusMessage)
	    			update += 1
	    		else
	    			next
	    		end
	    	else
	    		baru += 1
	    		product.save
	    	end
		end
	end

end
