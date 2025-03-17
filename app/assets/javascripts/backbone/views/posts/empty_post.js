Revenger.Views.EmptyPost = Backbone.View.extend({
  className: 'post',

  template: JST['posts/empty'],

  render: function() {
    this.$el.html(this.template());
    return this;
  }
});
