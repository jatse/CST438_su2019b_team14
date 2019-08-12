require 'rails_helper'

RSpec.describe 'Orders' do
    headers = {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
    
    #seed database
    before(:each) do 
        Order.create(itemId: 1, description: "Gold Ring", customerId: 1, price: 199.99, award: 0, total: 199.99)
        Order.create(itemId: 2, description: "Diamond Ring", customerId: 1, price: 89.99, award: 0, total: 89.99)
        Order.create(itemId: 1, description: "Gold Ring", customerId: 2, price: 199.99, award: 0, total: 199.99)
    end
    
    describe 'GET /orders/:id' do
        it "Failes to find order by id because order id does not exist" do
            get "/orders/#{5}", headers: headers
            expect(response).to have_http_status(404)
        end
        
        it "Retrieves an order by id" do
            get "/orders/#{1}", headers: headers
            expect(response).to have_http_status(200)
            json_response = JSON.parse(response.body)
            expect(json_response['id']).to eq 1
            expect(json_response['itemId']).to eq 1
            expect(json_response['customerId']).to eq 1
            expect(json_response['description']).to eq "Gold Ring"
            expect(json_response['price']).to eq "199.99"
            expect(json_response['award']).to eq "0.0"
            expect(json_response['total']).to eq "199.99"
            
        end
    end
    
    describe 'POST /orders' do
        it "Creates new order given customer and itemId" do
            #stub for method for calling to customer API, returns simple customer 
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1, :award => 0.0})
            #stub for method for calling to item API, returns simple item
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return({:id => 1, :description => "Gold Ring", :price => 199.99})
            # stub to simulate return codes from the customer and item APIs
            update_response = double
            allow(update_response).to receive(:code).and_return(204)
            allow_any_instance_of(OrdersController).to receive(:customer_update).and_return(update_response)
            allow_any_instance_of(OrdersController).to receive(:item_update).and_return(update_response)

            new_order = {email: '123@123.com', itemId: 1}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(201)
            json_response = JSON.parse(response.body)
            expect(json_response['itemId']).to eq 1
            expect(json_response['award']).to eq "0.0"
            expect(json_response['price']).to eq "199.99"
            expect(json_response['customerId']).to eq 1
            expect(json_response['total']).to eq "199.99"
            expect(json_response['description']).to eq "Gold Ring"
        end
        
        it "Failed to create a new order because of an invalid email" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return(nil)
            #stub for method for calling to item API, returns simple item
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return({:id => 1, :description => "Gold Ring", :price => 199.99})
            update_response = double
            allow(update_response).to receive(:code).and_return(204)
            allow_any_instance_of(OrdersController).to receive(:customer_update).and_return(update_response)
            allow_any_instance_of(OrdersController).to receive(:item_update).and_return(update_response)
            
            new_order = {email: '123@123.com', itemId: 1}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
        
        it "Failed to create a new order because of an invalid itemId" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1, :award => 0.0})
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return(nil)
            update_response = double
            allow(update_response).to receive(:code).and_return(204)
            allow_any_instance_of(OrdersController).to receive(:customer_update).and_return(update_response)
            allow_any_instance_of(OrdersController).to receive(:item_update).and_return(update_response)
            new_order = {email: '123@123.com', itemId: 1}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
        
        it "Failed to create a new order due to lack of email" do
            new_order = {itemId: 1}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
        
        it "Failed to create a new order due to lack of itemId" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1, :award => 0.0})
            new_order = {email: '123@123.com'}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
        
        it "Failed to create a new order due to lack of data from customer API" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1})
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return({:id => 1, :description => "Gold Ring", :price => 199.99})
            new_order = {email: '123@123.com'}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
        
        it "Failed to create a new order due to lack of data from item API" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1, :award => 0.0})
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return({:id => 1})
            new_order = {email: '123@123.com'}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end   
        
        it "Failed to create a new order due to item stock equal to zero or the item is unable to save to the database" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1, :award => 0.0})
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return({:id => 1, :description => "Gold Ring", :price => 199.99})
            update_response = double
            allow(update_response).to receive(:code).and_return(204)
            item_response = double
            allow(item_response).to receive(:code).and_return(400)
            allow_any_instance_of(OrdersController).to receive(:customer_update).and_return(update_response)
            allow_any_instance_of(OrdersController).to receive(:item_update).and_return(item_response)
            new_order = {email: '123@123.com', itemId: 1}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
        
        it "Failed to craete a new order due to customer unable to save to database" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1, :award => 0.0})
            allow_any_instance_of(OrdersController).to receive(:item_from_id).and_return({:id => 1, :description => "Gold Ring", :price => 199.99})
            update_response = double
            allow(update_response).to receive(:code).and_return(204)
            customer_response = double
            allow(customer_response).to receive(:code).and_return(400)
            allow_any_instance_of(OrdersController).to receive(:customer_update).and_return(customer_response)
            allow_any_instance_of(OrdersController).to receive(:item_update).and_return(update_response)
            new_order = {email: '123@123.com', itemId: 1}
            post '/orders', params: new_order.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
    end
    
    
end
    