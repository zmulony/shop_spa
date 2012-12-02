class HomeController < ApplicationController
	def index
	end

	def getCategories
		@categories = Category.all()
		
		respond_to do |format|
			format.json { render :json => @categories }
		end
	end

	def getProducts
		@products = Product.all()
		
		respond_to do |format|
			format.json { render :json => @products }
		end
	end

	def getCart
		respond_to do |format|
			format.json {render :json => @cart.to_json(include: :order_items)}
		end
	end

	def addItemToCart
		product = Product.find(params[:product_id])
		order_item = @cart.order_items.where(:product_id => product.id).first

		if order_item == nil
			order_item = @cart.order_items.create(:product => product, :quantity => 1, :price => product.price)
		else
			order_item.quantity += 1
			order_item.price += product.price
			order_item.update_attributes(params[:order_item])
		end

		respond_to do |format|
			format.json {render :json => "ok"}
		end
	end

	def removeItemFromCart
		order_item = @cart.order_items.find(params[:item_id])
		product = Product.find(order_item.product_id)

		if order_item.quantity == 1
			order_item.delete
		else
			order_item.quantity -= 1
			order_item.price -= product.price
			order_item.update_attributes(params[:order_item])
		end

		respond_to do |format|
			format.json {render :json => "ok"}
		end
	end
end