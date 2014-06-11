class Revenger.Models.Post extends Backbone.Model
  paramRoot: 'post'
  urlRoot: '/posts'
class Revenger.Collections.PostsCollection extends Backbone.Collection
  model: Revenger.Models.Post
  url: '/posts'
