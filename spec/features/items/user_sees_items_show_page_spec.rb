require 'rails_helper'

describe  'Items Show Page' do
  before :each do
    @m_1 = create(:user, role: 1)
    o_1 = Order.create(status: "pending", user_id: @m_1.id)
    @i_1 = @m_1.items.create(
      name: 'Flower Pot',
      description: 'Messy Pot',
      thumbnail: 'thumbnail',
      price: 4,
      inventory: 5,
      enabled: true
    )

    OrderItem.create(
      quantity: 2,
      price: @i_1.price,
      fulfilled: true,
      order_id: o_1.id,
      item_id: @i_1.id,
      created_at: 10.days.ago,
      updated_at: 1.days.ago
    )


  end
  context 'as any kind of user' do
    it "should show all item information" do
      visit item_path(@i_1)
      
      within "#item-image-#{@i_1.id}" do
        expect(page).to have_css("##{@i_1.thumbnail}")
      end

      expect(page).to have_content(@i_1.name)
      expect(page).to have_content(@i_1.description)
      expect(page).to have_content(@i_1.user.name)
      expect(page).to have_content(@i_1.inventory)
      expect(page).to have_content("Price: #{@i_1.price}")
      expect(page).to have_content("Average Fulfillment Time: #{@i_1.average_fulfillment_time}")
    end
  end
  context 'as a visitor or regular user' do
    it "should see a link to add this item to my cart" do
      visit item_path(@i_1)
      expect(page).to have_button("Add to Cart")
    end
  end

  context 'as a merchant' do
    it "should not see a link to add item to cart" do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_1)
      visit item_path(@i_1)
      expect(page).to_not have_button("Add to Cart")
    end
  end
  context 'as an admin' do
    it "should not see a link to add item to cart" do
      a_1 = create(:user, role: 2)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(a_1)
      visit item_path(@i_1)
      expect(page).to_not have_button("Add to Cart")
    end
  end
end
