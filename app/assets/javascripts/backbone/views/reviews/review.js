Revenger.Views.Review = Backbone.View.extend({
  initialize: function() {
    this.model.on('changed', this.render, this);
    this.model.on('update', this.render, this);
    // Bind the next method to this instance
    this.next = this.next.bind(this);
  },

  events: {
    'click [data-behavior=edit]': 'visibleEdit',
    'click [data-behavior=cancel]': 'invisibleEdit',
    'click [data-behavior=destroy]': 'destroy',
    'click [data-behavior=read]': 'read',
    'click [data-behavior=update]': 'update'
  },

  template: JST['reviews/review'],

  render: function() {
    this.$el.html(this.template({post: this.model}));
    return this;
  },

  visibleEdit: function(event) {
    event.preventDefault();
    $("[data-behavior=view-element]").hide();
    $("[data-behavior=edit-element]").show();
    $("#read").addClass('disabled').attr('data-behavior', '');
  },

  invisibleEdit: function(event) {
    event.preventDefault();
    $("[data-behavior=view-element]").show();
    $("[data-behavior=edit-element]").hide();
    $("#read").removeClass('disabled').attr('data-behavior', 'read');
  },

  update: function(event) {
    event.preventDefault();
    $('[data-behavior=update]').replaceWith(JST['posts/updating_button']());
    const duration = $('[data-behavior=duration]').find('button.active').data('value');
    const body = $("[data-behavior=body]").val();
    this.model.save({ duration: duration, body: body }, {
      success: this.successUpdate,
      error: (model, response) => {
        this.handleError(response);
        this.canceUpdateProcess();
      }
    });
  },

  successUpdate: function(model, response) {
    model.set(response);
    model.trigger('update');
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

  destroy: function(event) {
    event.preventDefault();
    if (!confirm('本当に削除して宜しいですか？')) return;
    const destroy_btn = $('[data-behavior=destroy]');
    Revenger.Views.Helper.process_button(destroy_btn);
    this.model.destroy({
      wait: true,
      success: (model, response) => {
        $.getJSON('/review/next').done((data) => {
          this.next(data);
        });
      }
    });
  },

  next: function(attrs) {
    this.model.off();
    this.countDown();
    if (typeof attrs.id === 'undefined') {
      const finish = new Revenger.Views.ReviewFinish();
      this.$el.html(finish.render().el);
    } else {
      this.model = new Revenger.Models.Post(attrs);
      this.initialize();
      this.model.trigger('changed');
    }
  },

  read: function(event) {
    event.preventDefault();
    const read_btn = $('[data-behavior=read]');
    Revenger.Views.Helper.process_button(read_btn);
    const review = new Revenger.Models.Review();
    const duration = $('[data-behavior=duration]').find('button.active').data('value');
    review.save({ post_id: this.model.get('id'), duration: duration }, {
      success: (model, response) => {
        this.next(response);
      },
      error: this.handleError
    });
  },

  countDown: function() {
    let count = $('[data-behavior=count]').data('count');
    if (count > 0) {
      $('title').html(`復習ページ (${count - 1}) - revenger`);
    } else {
      $('title').html("復習ページ - revenger");
    }
    $('[data-behavior=count]').html(count - 1);
    $('[data-behavior=count]').data('count', count - 1);
  },

  canceUpdateProcess: function() {
    const update_button = $('[data-behavior="updating"]');
    update_button.replaceWith(JST['posts/update_button']());
  }
});
