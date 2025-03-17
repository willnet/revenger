Revenger.Routers.Review = Backbone.Router.extend({
  routes: {
    '': 'index'
  },
  index: function() {
    const post = new Revenger.Models.Post();
    post.fetch({
      url: '/review',
      success: function() {
        const view = new Revenger.Views.Review({model: post});
        const html = view.render().el;
        $('#post').html(html);
      }
    });
  }
});
