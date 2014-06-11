class Revenger.Views.EmptyPost extends Backbone.View
  className: 'post'

  template: JST['posts/empty']

  render: ->
    @$el.html(@template())
    this
