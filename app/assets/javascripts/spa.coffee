# # # # # # # # # 
#    MODELS     #
# # # # # # # # # 

class Category
  constructor: (@id, @name) ->

class Product
  constructor: (@id, @name, @description, @price, @category_id) ->

class Cart
  constructor: ->
    @items = []
    @total_price = 0

  calculateTotalPrice: ->
    @total_price = @items.reduce ((acc, x) -> acc+x.price*x.quantity), 0
    @total_price

class OrderItem
  constructor: (@id, @product_id, @price, @quantity) ->

  increaseQuantity: =>
    @quantity = @quantity + 1

  decreaseQuantity: =>
    @quantity = @quantity - 1

# # # # # # # # # 
#    STORAGE    #
# # # # # # # # # 

class Storage
  constructor: ->

  storeJSON: (json) ->
    @json = json

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

  getCart: ->
    $.ajax({
            url: 'getCart.json'
            async: false
            dataType: 'json'
            success: (data, status) => @storeJSON(data)
      })
    @cart = new Cart()
    for item in @json.order_items
      item.price /= 100.0
    @cart.items = @json.order_items
    @cart.calculateTotalPrice()
    @cart

  addItemToCart: (product_id) ->
    $.ajax({
            type: 'POST'
            url: 'addItemToCart.json'
            async: false
            dataType: 'json'
            data: {product_id: product_id}
      })

# # # # # # # # # 
#    USECASES   #
# # # # # # # # # 

class ShopUseCase
  constructor: ->
    @categories = []
    @products = []
    @cart = null

    @category_products = []
    @category = null

  initHomePage: =>

  initProducts: (products) =>
    @products = products

  initCategories: (categories) =>
    @categories = categories

  initCart: (cart) =>
    @cart = cart

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

  showCartButton: =>


# # # # # # # # # 
#      GUI      #
# # # # # # # # # 

class Gui
  constructor: ->

  clearAll: =>
    $("#categories").html("")
    $("#category_products").html("")
    $("#product").html("")
    $("#cart").html("")


  createTemplate: (name, content = {}) =>
    source = $(name+"-template").html()
    template = Handlebars.compile(source)
    template(content)

  showCategories: (categories) =>
    @clearAll()
    $("#categories").html @createTemplate("#categories", categories)

    that = this
    $(".showCategoryProducts").click (event) ->
      event.preventDefault()
      category_id = $(this).data("category_id")
      that.showCategoryProductsClicked(category_id)

  showCategoryProductsClicked: (category_id) =>

  showCategoryProducts: (category, products) =>
    @clearAll()
    content = {category: category, products: products}
    $("#category_products").html @createTemplate("#category_products", content)

    that = this
    $(".showProduct").click (event) ->
      event.preventDefault()
      product_id = $(this).data("product_id")
      that.showProductClicked(product_id)

    $(".backToCategories").click (event) ->
      event.preventDefault()
      that.backToCategories()

  showProductClicked: (id) =>

  showProduct: (product) =>
    @clearAll()
    $("#product").html @createTemplate("#product", product)

    that = this
    $(".addProductToCart").click (event) ->
      event.preventDefault()
      product_id = $(this).data("product_id")
      that.addProductToCartClicked(product_id)

    $(".backToCategoryProducts").click (event) ->
      event.preventDefault()
      category_id = $(this).data("category_id")
      that.backToCategoryProducts(category_id)

  addProductToCartClicked: (product_id) =>

  showCart: (cart) =>
    @clearAll()
    $("#cart").html @createTemplate("#cart", cart)

    that = this
    $(".backToCategories").click (event) ->
      event.preventDefault()
      that.backToCategories()

  showCartButton: =>
    $("#cart_button").html @createTemplate("#cart_button")

    that = this
    $(".showCartButton").click (event) ->
      event.preventDefault()
      that.showCartButtonClicked()

  showCartButtonClicked: =>

  backToCategories: =>

  backToCategoryProducts: (category_id) =>


# # # # # # # # # 
#     GLUE      #
# # # # # # # # # 

class Glue
  constructor: (@useCase, @gui, @storage) ->
    AutoBind(@gui, @useCase)

    Before(@useCase, 'initHomePage', => @useCase.initCategories(@storage.getCategories()))
    Before(@useCase, 'initHomePage', => @useCase.initProducts(@storage.getProducts()))
    Before(@useCase, 'initHomePage', => @useCase.initCart(@storage.getCart()))
    After(@useCase, 'initHomePage', => @gui.showCategories(@useCase.categories))
    After(@useCase, 'initHomePage', => @gui.showCartButton())

    After(@useCase, 'showCategories', => @gui.showCategories(@useCase.categories))

    After(@useCase, 'showCategoryProductsClicked', (category_id) => @useCase.showCategoryProducts(category_id))
    Before(@useCase, 'showCategoryProducts', (category_id) => @useCase.findCategory(category_id))
    Before(@useCase, 'showCategoryProducts', (category_id) => @useCase.findCategoryProducts(category_id))
    After(@useCase, 'showCategoryProducts', => @gui.showCategoryProducts(@useCase.category, @useCase.category_products))

    After(@gui, 'showProductClicked', (id) => @useCase.showProduct(id))
    After(@useCase, 'showProduct', (id) => @gui.showProduct(@useCase.findProduct(id)))

    After(@gui, 'addProductToCartClicked', (product_id) => @storage.addItemToCart(product_id))
    After(@storage, 'addItemToCart', => @useCase.initCart(@storage.getCart()))

    After(@gui, 'showCartButtonClicked', => @useCase.showCartButton())
    After(@useCase, 'showCartButton', => @gui.showCart(@useCase.cart))

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
    useCase.initHomePage()

$(-> new ShopApp())