# # # # # # # # # 
#    MODELS     #
# # # # # # # # # 

class Category
  constructor: (@id, @name) ->

class Product
  constructor: (@id, @name, @description, @price, @category_id) ->

class Order
  constructor: (@id, @buyer_id, @confirmed) ->

class OrderItem
  constructor: (@product, @quantity) ->
    @total_price = @product.price * @quantity

  updateTotalPrice: =>
    @total_price = @product.price * @quantity

  inc: =>
    @quantity = @quantity + 1
    updateTotalPrice()

  dec: =>
    @quantity = @quantity - 1
    updateTotalPrice()

# # # # # # # # # 
#    STORAGE    #
# # # # # # # # # 

class Storage
  constructor: ->

  storeJSON: (json) ->
    @json = json

  getProducts: ->
    $.ajax({
            url: 'getProducts.json'
            async: false
            dataType: 'json'
            success: (data, status) => @storeJSON(data)
      })
    @products = []
    for p in @json
      @products.add(new Product(
                                p.id,
                                p.name,
                                p.description,
                                p.price/100.0,
                                p.category_id
      ))
    @products

  getCategories: ->
    $.ajax({
            url: 'getCategories.json'
            async: false
            dataType: 'json'
            success: (data, status) => @storeJSON(data)
      })
    @categories = []
    for c in @json
      @categories.add(new Category(
                                c.id,
                                c.name
      ))
    @categories

# # # # # # # # # 
#    USECASES   #
# # # # # # # # # 

class ShopUseCase
  constructor: ->
    @categories = []
    @products = []

    @category_products = []
    @category = null

  setInitialProducts: (products) =>
    @products = products

  setInitialCategories: (categories) =>
    @categories = categories

  showCategories: =>

  showCategoryProducts: (category_id) =>

  findCategory: (category_id) =>
    for category in @categories
      if category.id == category_id
        @category = category
        return @category

  findCategoryProducts: (category_id) =>
    @category_products = (product for product in @products when product.category_id == category_id)
    return @category_products

  showProduct: (id) =>

  findProduct: (id) =>
    for product in @products
      if product.id == id
        return product


# # # # # # # # # 
#      GUI      #
# # # # # # # # # 

class Gui
  constructor: ->

  clearAll: =>
    $("#categories").html("")
    $("#category_products").html("")
    $("#product").html("")


  createTemplate: (name, content = {}) =>
    source = $(name+"-template").html()
    template = Handlebars.compile(source)
    template(content)

  showCategories: (categories) =>
    @clearAll()
    $("#categories").html @createTemplate("#categories", categories)

    that = this
    $(".showCategoryProducts").click ->
      category_id = $(this).data("category_id")
      that.showCategoryProductsClicked(category_id)

  showCategoryProductsClicked: (category_id) =>

  showCategoryProducts: (category, products) =>
    @clearAll()
    content = {category: category, products: products}
    $("#category_products").html @createTemplate("#category_products", content)

    that = this
    $(".showProduct").click ->
      product_id = $(this).data("product_id")
      that.showProductClicked(product_id)

    $(".backToCategories").click ->
      that.backToCategories()

  showProductClicked: (id) =>

  showProduct: (product) =>
    @clearAll()
    $("#product").html @createTemplate("#product", product)

    that = this
    $(".backToCategoryProducts").click ->
      category_id = $(this).data("category_id")
      that.backToCategoryProducts(category_id)

  backToCategories: =>

  backToCategoryProducts: (category_id) =>


# # # # # # # # # 
#     GLUE      #
# # # # # # # # # 

class Glue
  constructor: (@useCase, @gui, @storage) ->
    AutoBind(@gui, @useCase)

    Before(@useCase, 'showCategories', => @useCase.setInitialCategories(@storage.getCategories()))
    Before(@useCase, 'showCategories', => @useCase.setInitialProducts(@storage.getProducts()))
    After(@useCase, 'showCategories', => @gui.showCategories(@useCase.categories))

    After(@useCase, 'showCategoryProductsClicked', (category_id) => @useCase.showCategoryProducts(category_id))
    Before(@useCase, 'showCategoryProducts', (category_id) => @useCase.findCategory(category_id))
    Before(@useCase, 'showCategoryProducts', (category_id) => @useCase.findCategoryProducts(category_id))
    After(@useCase, 'showCategoryProducts', => @gui.showCategoryProducts(@useCase.category, @useCase.category_products))

    After(@gui, 'showProductClicked', (id) => @useCase.showProduct(id))
    After(@useCase, 'showProduct', (id) => @gui.showProduct(@useCase.findProduct(id)))

    After(@gui, 'backToCategories', => @useCase.showCategories())
    After(@gui, 'backToCategoryProducts', (category_id) => @useCase.showCategoryProducts(category_id))

    LogAll(@useCase)
    LogAll(@gui)

# # # # # # # # # 
#   MAIN APP    #
# # # # # # # # # 

class ShopApp
  constructor: ->
    useCase = new ShopUseCase()
    gui = new Gui()
    storage = new Storage()
    glue = new Glue(useCase, gui, storage)
    useCase.showCategories()

$(-> new ShopApp())