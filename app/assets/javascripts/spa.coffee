# # # # # # # # # 
#    MODELS     #
# # # # # # # # # 

class @Category
  constructor: (@id, @name) ->

class @Product
  constructor: (@id, @name, @description, @price, @category_id) ->

class @Cart
  constructor: ->
    @items = []
    @total_price = 0
    @amount_of_items = 0
    @empty = true
    @has_one_item = false
    @has_many_items = false

  calculateAmountOfItems: ->
    @amount_of_items = @items.reduce ((acc, x) -> acc+x.quantity), 0
    if @amount_of_items == 0
      @empty = true
      @has_one_item = false
      @has_many_items = false
    if @amount_of_items == 1
      @empty = false
      @has_one_item = true
      @has_many_items = false
    if @amount_of_items > 1
      @empty = false
      @has_one_item = false
      @has_many_items = true

  calculateTotalPrice: ->
    @total_price = @items.reduce ((acc, x) -> acc+x.price), 0
    @total_price /= 100.0
    @total_price

class @OrderItem
  constructor: (@id, @product_id, @price, @quantity) ->
    @item_price = @price / 100.0

  increaseQuantity: =>
    @quantity = @quantity + 1

  decreaseQuantity: =>
    @quantity = @quantity - 1

# # # # # # # # # 
#    STORAGE    #
# # # # # # # # # 

class @Storage
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
      @cart.items.add(new OrderItem(item.id, item.product_id, item.price, item.quantity))
    @cart.calculateTotalPrice()
    @cart.calculateAmountOfItems()
    @cart

  addItemToCart: (product_id) ->
    $.ajax({
            type: 'POST'
            url: 'addItemToCart.json'
            async: false
            dataType: 'json'
            data: {product_id: product_id}
      })

  removeItemFromCart: (item_id) ->
    $.ajax({
            type: 'POST'
            url: 'removeItemFromCart.json'
            async: false
            dataType: 'json'
            data: {item_id: item_id}
      })

  finalizeOrder: (buyer) ->
    buyer['_method'] = 'PUT'
    $.ajax({
            type: 'POST'
            url: 'finalizeOrder.json'
            async: false
            dataType: 'json'
            data: buyer
      })

# # # # # # # # # 
#    USECASES   #
# # # # # # # # # 

class @ShopUseCase
  constructor: ->
    @categories = []
    @products = []
    @cart = null

    @category_products = []
    @category = null

    @results = []

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

  addProduct: (product_id) =>

  removeProduct: (item_id) =>

  checkConfirmation: =>
    if @cart.empty == true
      @sendNotification("Your cart is empty")
      return
    @proceedConfirmation()

  sendNotification: (text) =>

  proceedConfirmation: =>

  checkFinalization: (buyer) =>
    if buyer["firstname"] and buyer["lastname"]
      @proceedFinalization(buyer)
      return
    @sendNotification("You must fill in all fields of the form")

  proceedFinalization: (buyer) =>

  showSearchButton: =>

  search: (data) =>
    # just filter products to get search results
    # easier than sending => using ransack => geting results from backend
    @results = @products
    if data["name"]
      @results = @results.filter (product) -> product.name.indexOf(data["name"]) != -1
    if data["description"]
      @results = @results.filter (product) -> product.description.indexOf(data["description"]) != -1
    if data["min"]
      @results = @results.filter (product) -> product.price >= data["min"]
    if data["max"]
      @results = @results.filter (product) -> product.price <= data["max"]
    @results



# # # # # # # # # 
#      GUI      #
# # # # # # # # # 

class @Gui
  constructor: ->

  clearAll: =>
    $("#categories").html("")
    $("#category_products").html("")
    $("#product").html("")
    $("#cart").html("")
    $("#buyer_form").html("")
    $("#search_form").html("")
    $("#search_results").html("")

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

    $(".removeProductFromCart").click (event) ->
      event.preventDefault()
      item_id = $(this).data("item_id")
      that.removeProductFromCartClicked(item_id)

    $(".confirmOrder").click (event) ->
      event.preventDefault()
      that.confirmOrderClicked()

  removeProductFromCartClicked: (item_id) =>

  confirmOrderClicked: =>

  showCartButton: =>
    $("#cart_button").html @createTemplate("#cart_button")

    that = this
    $(".showCartButton").click (event) ->
      event.preventDefault()
      that.showCartButtonClicked()

  showCartButtonClicked: =>

  showCartNotification: (cart) =>
    $("#cart_notification").html @createTemplate("#cart_notification", cart)

  showNotification: (text) =>
    alert(text)

  showBuyerForm: =>
    @clearAll()
    $("#buyer_form").html @createTemplate("#buyer_form")

    that = this
    $(".finalizeOrder").click (event) ->
      event.preventDefault()
      buyer = {}
      $.each $("#buyer_form input"), (i, input) ->
        buyer[input.name] = input.value
      that.finalizeOrderClicked(buyer)

  finalizeOrderClicked: (buyer) =>

  showThanks: =>
    @showNotification(
      "Thank you\n
      Your request will be processed within a few days.\n
      We invite you to further purchases.\n"
      )

  showSearchButton: =>
    $("#search_button").html @createTemplate("#search_button")

    that = this
    $(".showSearchButton").click (event) ->
      event.preventDefault()
      that.showSearchButtonClicked()

  showSearchButtonClicked: =>

  showSearchForm: =>
    @clearAll()
    $("#search_form").html @createTemplate("#search_form")

    that = this
    $(".submitSearch").click (event) ->
      event.preventDefault()
      data = {}
      $.each $("#search_form input"), (i, input) ->
        data[input.name] = input.value
      that.submitSearchClicked(data)

  submitSearchClicked: (data) =>

  showSearchResults: (results) =>
    @clearAll()
    $("#search_results").html @createTemplate("#search_results", results)

    that = this
    $(".showProduct").click (event) ->
      event.preventDefault()
      product_id = $(this).data("product_id")
      that.showProductClicked(product_id)

    $(".backToCategories").click (event) ->
      event.preventDefault()
      that.backToCategories()

  backToCategories: =>

  backToCategoryProducts: (category_id) =>


# # # # # # # # # 
#     GLUE      #
# # # # # # # # # 

class @Glue
  constructor: (@useCase, @gui, @storage) ->
    AutoBind(@gui, @useCase)

    Before(@useCase, 'initHomePage', => @useCase.initCategories(@storage.getCategories()))
    Before(@useCase, 'initHomePage', => @useCase.initProducts(@storage.getProducts()))
    Before(@useCase, 'initHomePage', => @useCase.initCart(@storage.getCart()))
    After(@useCase, 'initHomePage', => @gui.showCategories(@useCase.categories))
    After(@useCase, 'initHomePage', => @gui.showCartButton())
    After(@useCase, 'initHomePage', => @gui.showSearchButton())

    After(@useCase, 'showCategories', => @gui.showCategories(@useCase.categories))

    After(@useCase, 'showCategoryProductsClicked', (category_id) => @useCase.showCategoryProducts(category_id))
    Before(@useCase, 'showCategoryProducts', (category_id) => @useCase.findCategory(category_id))
    Before(@useCase, 'showCategoryProducts', (category_id) => @useCase.findCategoryProducts(category_id))
    After(@useCase, 'showCategoryProducts', => @gui.showCategoryProducts(@useCase.category, @useCase.category_products))

    After(@gui, 'showProductClicked', (id) => @useCase.showProduct(id))
    After(@useCase, 'showProduct', (id) => @gui.showProduct(@useCase.findProduct(id)))

    After(@gui, 'addProductToCartClicked', (product_id) => @useCase.addProduct(product_id))
    Before(@useCase, 'addProduct', (product_id) => @storage.addItemToCart(product_id))
    AfterAll(@useCase, ['addProduct', 'removeProduct'], => @useCase.initCart(@storage.getCart()))
    After(@useCase, 'initCart', => @gui.showCart(@useCase.cart))
    After(@useCase, 'initCart', => @gui.showCartNotification(@useCase.cart))

    After(@gui, 'removeProductFromCartClicked', (item_id) => @useCase.removeProduct(item_id))
    Before(@useCase, 'removeProduct', (item_id) => @storage.removeItemFromCart(item_id))

    After(@gui, 'confirmOrderClicked', => @useCase.checkConfirmation())
    After(@useCase, 'sendNotification', (text) => @gui.showNotification(text))
    After(@useCase, 'proceedConfirmation', => @gui.showBuyerForm())

    After(@gui, 'finalizeOrderClicked', (buyer) => @useCase.checkFinalization(buyer))
    Before(@useCase, 'proceedFinalization', (buyer) => @storage.finalizeOrder(buyer))
    After(@useCase, 'proceedFinalization', => @gui.showThanks())
    After(@gui, 'showThanks', => @useCase.initCart(@storage.getCart()))

    After(@gui, 'showCartButtonClicked', => @useCase.showCartButton())
    After(@useCase, 'showCartButton', => @gui.showCart(@useCase.cart))

    After(@gui, 'showSearchButtonClicked', => @useCase.showSearchButton())
    After(@useCase, 'showSearchButton', => @gui.showSearchForm())

    After(@gui, 'submitSearchClicked', (data) => @useCase.search(data))
    After(@useCase, 'search', => @gui.showSearchResults(@useCase.results))

    After(@gui, 'backToCategories', => @useCase.showCategories())
    After(@gui, 'backToCategoryProducts', (category_id) => @useCase.showCategoryProducts(category_id))

    LogAll(@useCase)
    LogAll(@gui)

# # # # # # # # # 
#   MAIN APP    #
# # # # # # # # # 

class @ShopApp
  constructor: ->
    useCase = new ShopUseCase()
    gui = new Gui()
    storage = new Storage()
    glue = new Glue(useCase, gui, storage)
    useCase.initHomePage()

$(-> new ShopApp())