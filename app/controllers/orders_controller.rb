class OrdersController < ApplicationController
    #===========================================================================
    #Adds a new order to database.
    #POST /orders
    #===========================================================================
    def create
        # checks to see if it has an email address
        if params.has_key?(:email)
            customer = customer_from_email(params['email'])
            #receive customer information from customer API
            if customer != nil
                if params.has_key?(:itemId)
                    item = item_from_id(params['itemId'])
                    #receive item information from item API
                    if item != nil
                        # calculates the total from the price and award values
                        calculate_total = item[:price] - customer[:award]
                        # creates entry for new order based off of the information
                        # from the item and customer APIs
                        newOrder = Order.new(itemId: item[:id], 
                        description: item[:description], 
                        customerId: customer[:id], price: item[:price], 
                        award: customer[:award], total: calculate_total)
                        # if the values in the order are correct the value is 
                        # saved into the database, otherwise an error is returned
                        if newOrder.save
                            render(json: newOrder, status: 201)
                        else
                            render(json: newOrder.errors, status: 400)
                        end
                    else
                        head :bad_request
                    end
                else
                    head :bad_request
                end
            else
                head :bad_request
            end
        else
            head :bad_request
        end
    end
    
    #===========================================================================
    #Retrieve order by id.
    #GET /orders/:id
    #===========================================================================
    def show
        # if the id is submitted, find order by id
        if params.has_key?(:id)
            order = Order.find_by(id: params[:id])
            # if the order is found in the database then the data of the order
            # is returned, otherwise it returns a 404 error
            if order != nil
                render(json: order, status: 200 )
            else
                head :not_found
            end
        else
            head :not_found
        end
    end
    
    #===========================================================================
    #Retrieve order by customerId or customer email.
    #GET /orders
    #===========================================================================
    def index
        #if customer email is submitted, find customerId
        if params.has_key?(:email)
            customer = customer_from_email(params['email'])
            #read orders if valid customer found
            if customer != nil
                orders = Order.where(:customerId => customer[:id])
            else
                orders = nil
            end
            
        #if customer id is submitted, read orders
        elsif params.has_key?(:customerId)
            orders = Order.where(:customerId => params['customerId'])
        end
        
        #return empty array if no orders found
        if orders.nil?
            render(json: Array.new, status: 200)
        #otherwise convert orders to hash and return status 200 OK
        else
            ordersArray = to_hash(orders)
            render(json: ordersArray, status: 200)
        end
    end
    
    
    private
        #=======================================================================
        #Input: An array of order objects
        #Returns an array of orders with hashed attributes
        #=======================================================================
        def to_hash(orders)
            #hashes of orders will be kept in an array
            orderArray = Array.new
            
            #iterate through all orders
            orders.each do |order|
                #convert object to hash
                orderhash = {
                    :id => order.id,
                    :itemId => order.itemId, 
                    :description => order.description, 
                    :customerId => order.customerId,
                    :price => order.price,
                    :award => order.award,
                    :total => order.total,
                    :created_at => order.created_at,
                    :updated_at => order.updated_at
                }
                #append to array of orders
                orderArray << orderhash
            end
            
            return orderArray
        end
        
        #=======================================================================
        #Input: Customer email address
        #Makes API call to customer database, returns hash of customer object
        #=======================================================================
        def customer_from_email(email)
            HTTParty.get('http://localhost:8081/customers', query: {email: email})
        end
        
        def item_from_id(id)
            HTTParty.get('http://localhost:8082/items', query: {id: id}) 
        end
end