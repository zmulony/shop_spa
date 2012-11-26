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

  # showCategories: (categories) =>
  #   source = $("#categories-template").html()
  #   template = Handlebars.compile(source)
  #   data = { categories : [] }
  #   for category in categories
  #     data.categories.push({
  #                             name: category.name
  #     })
  #   html = template(data)
  #   $("#categories").html(html)

  # showCategory: (category, products) =>
  #   source = $("#category-template").html()
  #   template = Handlebars.compile(source)
  #   data = { category : category, products : [] }
  #   for product in products
  #     data.products.push({
  #                           name: product.name,
  #                           price: product.price,
  #                           description: product.description
  #     })
  #   html = template(data)
  #   $("#category").html(html)

  showProducts: (products) =>
    @clearAll()
    $("#category_products").html @createTemplate("#category_products", products)

    that = this
    $(".showProduct").click ->
      product_id = $(this).data("product_id")
      that.showProductClicked(product_id)

  showProductClicked: (id) =>

  showProduct: (product) =>
    @clearAll()
    $("#product").html @createTemplate("#product", product)

    that = this
    $(".backToProducts").click ->
      that.backToProducts()

  backToProducts: =>


# # # # # # # # # 
#     GLUE      #
# # # # # # # # # 

class Glue
  constructor: (@useCase, @gui, @storage) ->
    AutoBind(@gui, @useCase)

    Before(@useCase, 'showAllProducts', => @useCase.setInitialProducts(@storage.getProducts()))
    After(@useCase, 'showAllProducts', => @gui.showProducts(@useCase.products))

    After(@gui, 'showProductClicked', (id) => @useCase.showProduct(id))
    After(@useCase, 'showProduct', (id) => @gui.showProduct(@useCase.findProduct(id)))

    After(@gui, 'backToProducts', => @useCase.showAllProducts())

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