require 'rails_helper'

describe "As a Merchant" do

    context "navigation" do
        it 'can view the merchant nav bar' do
            merchant = create(:user, role:1)

            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

            visit root_path

            within ".nav" do
                expect(page).to have_content("Home")
                expect(page).to have_content("Browse Items")
                expect(page).to have_content("Browse Merchants")
                expect(page).to have_content("Logout")
                expect(page).to have_content("Dashboard")
            end
            click_on "Dashboard"
            expect(current_path).to eq(dashboard_path)

        end
        it 'cannot be seen by a visitor' do
            visit root_path

            within ".nav" do
                expect(page).to_not have_content("Profile")
                expect(page).to_not have_content("Orders")
                expect(page).to_not have_content("Logout")
                expect(page).to_not have_content("Dashboard")
            end
            visit dashboard_path

            expect(page).to have_content("The page you were looking for doesn't exist.")
        end
        it 'dashboard cannot be seen by a user' do
            user = create(:user)

            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

            visit root_path

            within ".nav" do
                expect(page).to_not have_content("Dashboard")
            end
            visit dashboard_path

            expect(page).to have_content("The page you were looking for doesn't exist.")
        end
    end

    context "Dashboard" do
        it 'merchant can see (but not edit) their profile data on the dashboard' do
            merchant = create(:user, role: 1)
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

            visit dashboard_path

            expect(page).to have_content(merchant.name)
            expect(page).to have_content(merchant.email)
            expect(page).to have_content(merchant.address)
            expect(page).to have_content(merchant.city)
            expect(page).to have_content(merchant.state)
            expect(page).to have_content(merchant.zip)
        end
    end

    context "Statistics" do 
        it 'can display the top 5 items sold by quantity on show page' do 
            merchant = create(:user, role: 1)
            item_1 = create(:item, user:merchant)
            item_2 = create(:item, user:merchant)
            item_3 = create(:item, user:merchant)
            item_4 = create(:item, user:merchant)
            item_5 = create(:item, user:merchant)
            item_6 = create(:item, user:merchant)
            order = create(:completed_order, user_id:merchant.id)
            create(:fulfilled_order_item,  order:order, item: item_1, price: 1, quantity: 25)
            create(:fulfilled_order_item,  order:order, item: item_2, price: 1, quantity: 25)
            create(:fulfilled_order_item,  order:order, item: item_3, price: 1, quantity: 25)
            create(:fulfilled_order_item,  order:order, item: item_4, price: 1, quantity: 25)
            create(:fulfilled_order_item,  order:order, item: item_5, price: 1, quantity: 25)
            create(:fulfilled_order_item,  order:order, item: item_6, price: 1, quantity: 1)

            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

            visit dashboard_path

            within "#top-5-items" do 
                expect(page).to have_content(item_1.name) 
                expect(page).to have_content(item_2.name) 
                expect(page).to have_content(item_3.name) 
                expect(page).to have_content(item_4.name) 
                expect(page).to have_content(item_5.name) 
            end
        end 
    end

    context "/dashboard/items" do
        it 'can see a toggled button for enable/disable next to each item' do
            merchant = create(:user, role: 1)
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
            user = create(:user)
            item_1 = create(:item, user: merchant, thumbnail: 'oldguy.jpeg')
            
            visit dashboard_items_path 
            within "#item-#{item_1.id}" do
                click_button "Enable"
            end

            item_1.reload

            expect(item_1.enabled).to be_truthy 
        end
    end
end
