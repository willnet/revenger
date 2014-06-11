class Revenger.Views.ReviewFinish extends Backbone.View
  template: JST['reviews/finish']
  render: ->
    @$el.html(@template())
    this
