class Revenger.Routers.Posts extends Backbone.Router
  routes:
    '': 'index'
  index: ->
    collection = new Revenger.Collections.PostsCollection
    collection.fetch data: Revenger.query, success: ->
      view = new Revenger.Views.PostIndex(collection: collection)
      html = view.render().el
      $('#posts').html(html)