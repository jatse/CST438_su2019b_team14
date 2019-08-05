require 'rails_helper'

RSpec.describe 'Orders' do
    headers = {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
    
    #seed database
    before(:each) do 
        Order.create(itemId: 1, description: "Gold Ring", customerId: 1, price: 199.99, award: 0, total: 199.99)
        Order.create(itemId: 2, description: "Diamond Ring", customerId: 1, price: 89.99, award: 0, total: 89.99)
        Order.create(itemId: 1, description: "Gold Ring", customerId: 2, price: 199.99, award: 0, total: 199.99)
    end
    
    describe "GET /orders" do
        it "Reads multiple orders for valid customer ID" do
            get '/orders?customerId=1', headers:headers
            expect(response).to have_http_status(200)
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 2
            #first order record check
            expect(json_response[0]['itemId']).to eq 1
            expect(json_response[0]['description']).to eq "Gold Ring"
            expect(json_response[0]['customerId']).to eq 1
            expect(json_response[0]['price']).to eq "199.99"
            expect(json_response[0]['award']).to eq "0.0"
            expect(json_response[0]['total']).to eq "199.99"
            #second order record check
            expect(json_response[1]['itemId']).to eq 2
            expect(json_response[1]['description']).to eq "Diamond Ring"
            expect(json_response[1]['customerId']).to eq 1
            expect(json_response[1]['price']).to eq "89.99"
            expect(json_response[1]['award']).to eq "0.0"
            expect(json_response[1]['total']).to eq "89.99"
        end
        
        it "Reads single order for valid customer ID" do
            get '/orders?customerId=2', headers:headers
            expect(response).to have_http_status(200)
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 1
            #order record check
            expect(json_response[0]['itemId']).to eq 1
            expect(json_response[0]['description']).to eq "Gold Ring"
            expect(json_response[0]['customerId']).to eq 2
            expect(json_response[0]['price']).to eq "199.99"
            expect(json_response[0]['award']).to eq "0.0"
            expect(json_response[0]['total']).to eq "199.99"
        end
        
        it "Returns empty array for customerId with no orders" do
            get '/orders?customerId=999', headers:headers
            expect(response).to have_http_status(200)
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 0
        end
        
        it "Reads multiple orders with valid email" do
            #stub of method for calling to customer API, returns simple customer with id field only
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 1})
            get '/orders?email=fakeuser@domain.com', headers:headers
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 2
            #first order record check
            expect(json_response[0]['itemId']).to eq 1
            expect(json_response[0]['description']).to eq "Gold Ring"
            expect(json_response[0]['customerId']).to eq 1
            expect(json_response[0]['price']).to eq "199.99"
            expect(json_response[0]['award']).to eq "0.0"
            expect(json_response[0]['total']).to eq "199.99"
            #second order record check
            expect(json_response[1]['itemId']).to eq 2
            expect(json_response[1]['description']).to eq "Diamond Ring"
            expect(json_response[1]['customerId']).to eq 1
            expect(json_response[1]['price']).to eq "89.99"
            expect(json_response[1]['award']).to eq "0.0"
            expect(json_response[1]['total']).to eq "89.99"
        end
        
        it "Reads single order with valid email" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 2})
            get '/orders?email=fakeuser@domain.com', headers:headers
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 1
            #order record check
            expect(json_response[0]['itemId']).to eq 1
            expect(json_response[0]['description']).to eq "Gold Ring"
            expect(json_response[0]['customerId']).to eq 2
            expect(json_response[0]['price']).to eq "199.99"
            expect(json_response[0]['award']).to eq "0.0"
            expect(json_response[0]['total']).to eq "199.99"
        end
        
        it "Returns empty array for valid email but no orders" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return({:id => 999})
            get '/orders?email=fakeuser@domain.com', headers:headers
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 0
        end
        
        it "Returns empty array for invalid email" do
            allow_any_instance_of(OrdersController).to receive(:customer_from_email).and_return(nil)
            get '/orders?email=fakeuser@domain.com', headers:headers
            json_response = JSON.parse(response.body)
            expect(json_response.length).to eq 0
        end
    end
    
end
    