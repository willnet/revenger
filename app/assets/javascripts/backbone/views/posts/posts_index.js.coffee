class Revenger.Views.PostIndex extends Backbone.View
  id: 'posts'
  render: ->
    if @collection.length is 0
      view = new Revenger.Views.EmptyPost
      @$el.append(view.render().el)
      return this

    @collection.each (post) =>
      view = new Revenger.Views.Post(model: post)
      @$el.append(view.render().el)
    this