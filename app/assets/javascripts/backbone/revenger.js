//= require_self
//= require_tree ../templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./routers

window.Revenger = {
  Models: {},
  Collections: {},
  Routers: {},
  Views: {},
  initReview: (query) => {
    new Revenger.Routers.Review();
    Backbone.history.start();
  },
  initPostIndex: function(query) {
    this.query = query;
    new Revenger.Routers.Posts();
    Backbone.history.start();
  }
};
