require 'httparty'

#HTTParty class for common request configuations
class Connection
    include HTTParty

    headers 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'
    format :json
    
    #change base uri so http methods retrieve ORDERS
    def Connection.target_orders_api
        base_uri 'http://localhost:8080/'
    end
    
    #change base uri so http methods retrieve CUSTOMERS
    def Connection.target_customers_api
        base_uri 'http://localhost:8081/'
    end
    
    #change base uri so http methods retrieve ITEMS
    def Connection.target_items_api
        base_uri 'http://localhost:8082/'
    end
end

#initialize choice
choice = nil

def outputResponse(response)
    puts "status code #{response.code}"
    puts response
    puts #new line
end

#main application loop
while choice != '7' do
    #output menu for selection
    puts "What do you want to do?"
    puts "1 - New order"
    puts "2 - Retrieve order"
    puts "3 - New customer"
    puts "4 - Lookup customer"
    puts "5 - New item"
    puts "6 - Lookup item"
    puts "7 - Quit"
    choice = gets.chomp!
    
    
    case choice
        #=======================================================================
        # 1 - NEW ORDER
        #=======================================================================
        when '1'
            #set connection to orders API
            Connection.target_orders_api
            
            #get new order information
            puts "Enter item id"
            item_id = gets.chomp!
            puts "Enter customer email"
            customer_email = gets.chomp!
            obj = {itemId: item_id, email: customer_email}
            outputResponse(Connection.post('/orders', :body => obj.to_json))
            
            
            
        #=======================================================================
        # 2 - RETRIEVE ORDER
        #=======================================================================
        when '2'
            #set connection to orders API
            Connection.target_orders_api
            
            #get search paramter type
            puts "retrieve by:"
            puts "1 - order id"
            puts "2 - customer email"
            puts "3 - customer id"
            userInput = gets.chomp!
            
            if userInput == "1"
                #get email to search
                puts "enter order id"
                userInput = gets.chomp!
                #print response object from request
                outputResponse(Connection.get('/orders/#{userInput}'))
            elsif userInput == "2"
                #get email to search
                puts "enter customer email"
                userInput = gets.chomp!
                #print response object from request
                outputResponse(Connection.get('/orders', query: {email: userInput}))
            elsif userInput == "3"
                #get id to search
                puts "enter customer id"
                userInput = gets.chomp!
                #print response object from request
                outputResponse(Connection.get('/orders', query: {customerId: userInput}))
            end
            
        #=======================================================================
        # 3 - NEW CUSTOMER
        #=======================================================================
        when '3'
            #set connection to customers API
            Connection.target_customers_api
            
            #get new customer parameters
            puts "enter lastName, firstName and email for new customer"
            #convert input into a hash
            userInput = gets.chomp!.split
            obj = {'lastName' => userInput[0], 'firstName' => userInput[1], 'email' => userInput[2]}
            #print response object from request
            outputResponse(Connection.post('/customers', :body => obj.to_json))
        
        #=======================================================================    
        # 4 - LOOKUP CUSTOMER
        #=======================================================================
        when '4'  
            #set connection to customers API
            Connection.target_customers_api
            
            #get search paramter type
            puts "lookup by:"
            puts "1 - customer email"
            puts "2 - customer id"
            userInput = gets.chomp!
            
            if userInput == "1"
                #get email to search
                puts "enter customer email"
                userInput = gets.chomp!
                #print response object from request
                outputResponse(Connection.get('/customers', query: {email: userInput}))
            elsif userInput == "2"
                #get id to search
                puts "enter customer id"
                userInput = gets.chomp!
                #print response object from request
                outputResponse(Connection.get('/customers', query: {id: userInput}))
            end
        
        #=======================================================================    
        # 5 - NEW ITEM
        #=======================================================================
        when '5'
            #set connection to items API
            Connection.target_items_api
            
            puts "enter item description"
            name = gets.chomp!
            puts 'enter item price'
            cost = gets.chomp!
            puts 'enter item stockQty'
            numOnHand = gets.chomp!
            obj = {description: name, price: cost, stock: numOnHand}
            outputResponse(Connection.post('/items', :body => obj.to_json))
            
        #=======================================================================    
        # 6 - LOOKUP ITEM
        #=======================================================================
        when '6'
            #set connection to items API
            Connection.target_items_api
            
            puts "enter id of item to lookup"
            idInput = gets.chomp!
            outputResponse(Connection.get('/items', query: {id: idInput}))
    end
end