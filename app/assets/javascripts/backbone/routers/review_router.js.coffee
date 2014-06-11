class Revenger.Routers.Review extends Backbone.Router
  routes:
    '': 'index'
  index: ->
    post = new Revenger.Models.Post()
    post.fetch url: '/review', success: ->
      view = new Revenger.Views.Review(model: post)
      html = view.render().el
      $('#post').html(html)
