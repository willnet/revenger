Revenger.Views.Post = Backbone.View.extend({
  className: 'post',

  initialize: function() {
    this.model.on('update', this.render, this);
    this.model.on('destroy', this.remove, this);
  },

  events: {
    'click [data-behavior=edit]': 'visibleEdit',
    'click [data-behavior=cancel]': 'invisibleEdit',
    'click [data-behavior=destroy]': 'destroy',
    'click [data-behavior=update]': 'update'
  },

  template: JST['posts/post'],

  render: function() {
    this.$el.html(this.template({post: this.model}));
    return this;
  },

  visibleEdit: function(event) {
    event.preventDefault();
    this.$el.find('[data-behavior=view-element]').hide();
    this.$el.find('[data-behavior=edit-element]').show();
  },

  invisibleEdit: function(event) {
    event.preventDefault();
    this.$el.find('[data-behavior=view-element]').show();
    this.$el.find('[data-behavior=edit-element]').hide();
  },

  destroy: function(event) {
    event.preventDefault();
    if (!confirm('本当に削除して宜しいですか？')) return;
    const destroy_btn = this.$el.find('[data-behavior=destroy]');
    Revenger.Views.Helper.process_button(destroy_btn);
    this.model.destroy({
      success: function(model, response) {
        model.trigger('destroy');
      }
    });
  },

  update: function(event) {
    event.preventDefault();
    this.$el.find('[data-behavior=update]')
      .replaceWith(JST['posts/updating_button']());
    const duration = this.$el.find('[data-behavior=duration]').find('button.active').data('value');
    const body = this.$el.find('[data-behavior=body]').val();

    this.model.save({ duration: duration, body: body }, {
      success: function(model, response) {
        model.trigger('update');
      },
      error: (model, response) => {
        this.handleError(response);
        this.canceUpdateProcess();
      }
    });
  },

  handleError: function(response) {
    if (response.status === 422) {
      const errors = $.parseJSON(response.responseText).errors;
      let str = '';
      for (const attribute in errors) {
        const messages = errors[attribute];
        for (const message of messages) {
          str += `${I18n.t(attribute, {scope: 'activerecord.attributes.post'})}${message}`;
        }
      }
      alert(str);
    }
  },

  canceUpdateProcess: function() {
    const update_button = $('[data-behavior="updating"]');
    update_button.replaceWith(JST['posts/update_button']());
  }
});
