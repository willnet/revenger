Revenger.Views.ReviewFinish = Backbone.View.extend({
  template: JST['reviews/finish'],
  render: function() {
    this.$el.html(this.template());
    return this;
  }
});
