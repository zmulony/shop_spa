#= require application

describe "ShopUseCase", ->
	beforeEach: =>
		@useCase = new ShopUseCase()

		@category1 = new Category(1, "meat")
		@category2 = new Category(2, "fruits")

		@product1 = new Product(1, "pork", "fresh piece of meat", 9.76, 1)
		@product2 = new Product(2, "chicken", "better than KFC", 5.33, 1)
		@product3 = new Product(3, "orange", "fresh, juicy and healty", 3.89, 2)
		@product4 = new Product(4, "apple", "shiny red apples, Newton approves", 0.67, 2)

		@useCase.categories.add(@category1)
		@useCase.categories.add(@category2)

		@useCase.products.add(@product1)
		@useCase.products.add(@product2)
		@useCase.products.add(@product3)
		@useCase.products.add(@product4)

	describe "findCategory", =>
		it "should be able to find category with given id", =>
			expect(@useCase.findCategory(1)).toEqual @category1
			expect(@useCase.category).toEqual @category1

	describe "findCategoryProducts", =>
		it "should be able to find products from category with given id", =>
			expect(@useCase.findCategoryProducts(1)).toEqual [@product1, @product2]
			expect(@useCase.category_products).toEqual [@product1, @product2]

	describe "findProduct", =>
		it "should be able to find product with given id", =>
			expect(@useCase.findProduct(3)).toEqual @product3
			expect(@useCase.product).toEqual @product3

	describe "search", =>
		beforeEach: =>
			@data = {name: "", description: "", min: "", max: ""}

		describe "when given data contains only false values", =>
			it "should return all products", =>
				expect(@useCase.search(@data)).toEqual @useCase.products

		describe "when given data contains some false values and some true values", =>
			it "should return products which match given name", =>
				@data[name] = "apple"
				expect(@useCase.search(@data)).toEqual @product4

				@data[name] = "or"
				expect(@useCase.search(@data)).toEqual [@product1, @product3]

			it "should return products which match given description", =>
				@data[description] = "fresh"
				expect(@useCase.search(@data)).toEqual [@product1, @product3]

			it "should return products which have price greater than or equal to min", =>
				@data[min] = 3.89
				expect(@useCase.search(@data)).toEqual [@product1, @product2, @product3]

			it "should return products which have price less than or equal to max", =>
				@data[max] = 5.33
				expect(@useCase.search(@data)).toEqual [@product2, @product3, @product4]

			it "should return products which have price between min and max values", =>
				@data[min] = 3.89
				@data[max] = 5.33
				expect(@useCase.search(@data)).toEqual [@product2, @product3]