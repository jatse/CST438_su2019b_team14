require 'httparty'

class OrdersController < ApplicationController
    
    #HTTParty class for common request configuations
    class Connection
        include HTTParty
        
        headers 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'
        format :json
        #base_uri not set.
        #Use 'http://localhost:8081/' for customer API base_uri
        #Use 'http://localhost:8082/' for item API base_uri
    end
    
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
    end
end