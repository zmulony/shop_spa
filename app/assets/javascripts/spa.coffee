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
                                p.price,
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
                                p.name
      ))
    @categories

# # # # # # # # # 
#    USECASES   #
# # # # # # # # # 

class ShopUseCase
  constructor: ->
    @categories = []
    @products = []

  setInitialProducts: (products) =>
    @products = products

  setInitialCategories: (categories) =>
    @categories = categories

  showAllProducts: =>

# # # # # # # # # 
#      GUI      #
# # # # # # # # # 

class Gui
  constructor: ->

  showProducts: (products) =>
    source = $("#products-template").html()
    template = Handlebars.compile(source)
    data = { products : [] }
    for product in products
      data.products.push({
                            name: product.name,
                            price: product.price,
                            description: product.description
      })
    html = template(data)
    $("#products").html(html)

# # # # # # # # # 
#     GLUE      #
# # # # # # # # # 

class Glue
  constructor: (@useCase, @gui, @storage) ->
    AutoBind(@gui, @useCase)
    Before(@useCase, 'showAllProducts', => @useCase.setInitialProducts(@storage.getProducts()))
    After(@useCase, 'showAllProducts', => @gui.showProducts(@useCase.products))
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
    useCase.showAllProducts()

$(-> new ShopApp())