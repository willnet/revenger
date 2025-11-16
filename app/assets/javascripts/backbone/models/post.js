Revenger.Models.Post = Backbone.Model.extend({
  paramRoot: 'post',
  urlRoot: '/posts'
});

Revenger.Collections.PostsCollection = Backbone.Collection.extend({
  model: Revenger.Models.Post,
  url: '/posts.json'
});
