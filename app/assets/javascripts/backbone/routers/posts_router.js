Revenger.Routers.Posts = Backbone.Router.extend({
  routes: {
    '': 'index'
  },
  index: function() {
    const collection = new Revenger.Collections.PostsCollection();
    collection.fetch({
      data: Revenger.query,
      success: function() {
        const view = new Revenger.Views.PostIndex({collection: collection});
        view.setElement($('#posts')).render();
      }
    });
  }
});
