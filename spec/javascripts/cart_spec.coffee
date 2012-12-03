#= require application

describe "Cart", ->
	describe "when has no items", ->
		beforeEach: =>
			@cart = new Cart()

		it "should be able to calculate total price", =>
			@cart.calculateTotalPrice()
			expect(@cart.total_price).toEqual 0.0

		it "should be able to calculate amount of items", =>
			@cart.calculateAmountOfItems()
			expect(@cart.amount_of_items).toEqual 0

		it "should be empty", =>
			expect(@cart.empty).toEqual true
			expect(@cart.has_one_item).toEqual false
			expect(@cart.has_many_items).toEqual false

	describe "when has some items", ->
		beforeEach: =>
			@cart = new Cart()
			@cart.items.add(new OrderItem(1, 1, 100, 1))
			@cart.items.add(new OrderItem(2, 5, 567, 3))

		it "should be able to calculate total price", =>
			@cart.calculateTotalPrice()
			expect(@cart.total_price).toEqual 6.67

		it "should be able to calculate amount of items", =>
			@cart.calculateAmountOfItems()
			expect(@cart.amount_of_items).toEqual 2

		it "should not be empty", =>
			expect(@cart.empty).toEqual false
			expect(@cart.has_one_item).toEqual false
			expect(@cart.has_many_items).toEqual true