Revenger.Views.PostIndex = Backbone.View.extend({
  id: 'posts',
  render: function() {
    if (this.collection.length === 0) {
      const view = new Revenger.Views.EmptyPost();
      this.$el.append(view.render().el);
      return this;
    }

    this.collection.each((post) => {
      const view = new Revenger.Views.Post({model: post});
      this.$el.append(view.render().el);
    });
    return this;
  }
});
