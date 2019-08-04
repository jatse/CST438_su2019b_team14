class OrdersController < ApplicationController
    #===========================================================================
    #Adds a new order to database.
    #POST /orders
    #===========================================================================
    def create
    end
    
    #===========================================================================
    #Retrieve order by id.
    #GET /orders/:id
    #===========================================================================
    def show
    end
    
    #===========================================================================
    #Retrieve order by customerId or customer email.
    #GET /orders
    #===========================================================================
    def index
        #if customer email is submitted, find customerId
        if params.has_key?(:email)
            customer = HTTParty.get('http://localhost:8081/customers', query: {email: params['email']})
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
    
end