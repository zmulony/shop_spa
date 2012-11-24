class HomeController < ApplicationController
	def index
	end

	def getProducts
		@products = Product.all()
		
		respond_to do |format|
			format.json { render :json => @products }
		end
	end
end