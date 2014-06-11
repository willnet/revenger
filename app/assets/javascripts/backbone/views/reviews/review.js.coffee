class Revenger.Views.Review extends Backbone.View
  initialize: ->
    @model.on('changed', @render, this)
    @model.on('update', @render, this)

  events:
    'click [data-behavior=edit]': 'visibleEdit'
    'click [data-behavior=cancel]': 'invisibleEdit'
    'click [data-behavior=destroy]': 'destroy'
    'click [data-behavior=read]': 'read'
    'click [data-behavior=update]': 'update'

  template: JST['reviews/review']

  render: ->
    @$el.html(@template(post: @model))
    this

  visibleEdit: (event) ->
    event.preventDefault()
    $("[data-behavior=view-element]").hide()
    $("[data-behavior=edit-element]").show()
    $("#read").addClass('disabled').attr('data-behavior', '')

  invisibleEdit: (event) ->
    event.preventDefault()
    $("[data-behavior=view-element]").show()
    $("[data-behavior=edit-element]").hide()
    $("#read").removeClass('disabled').attr('data-behavior', 'read')

  update: (event) ->
    event.preventDefault()
    $('[data-behavior=update]').replaceWith(JST['posts/updating_button']())
    duration = $('[data-behavior=duration]').find('button.active').data('value')
    body = $("[data-behavior=body]").val()
    @model.save { duration: duration, body: body },
      success: @successUpdate
      error: (model, response) =>
        @handleError(response)
        @canceUpdateProcess()

  successUpdate: (model, response) ->
    model.set(response)
    model.trigger('update')

  handleError: (response) ->
    if response.status is 422
      errors = $.parseJSON(response.responseText).errors
      str = ''
      for attribute, messages of errors
        str += "#{I18n.t(attribute, {scope: 'activerecord.attributes.post'})}#{message}" for message in messages
      alert str

  destroy: (event) ->
    event.preventDefault()
    return unless confirm '本当に削除して宜しいですか？'
    destroy_btn = $('[data-behavior=destroy]')
    Revenger.Views.Helper.process_button(destroy_btn)
    @model.destroy
      wait: true
      success: (model, response) =>
        $.getJSON('/review/next').done (data) =>
          @next(data)

  next: (attrs) =>
    @model.off()
    @countDown()
    if typeof attrs.id is 'undefined'
      finish = new Revenger.Views.ReviewFinish
      @$el.html(finish.render().el)
    else
      @model = new Revenger.Models.Post(attrs)
      @initialize()
      @model.trigger('changed')

  read: (event) ->
    event.preventDefault()
    read_btn = $('[data-behavior=read]')
    Revenger.Views.Helper.process_button(read_btn)
    review = new Revenger.Models.Review
    duration = $('[data-behavior=duration]').find('button.active').data('value')
    review.save { post_id: @model.get('id'), duration: duration },
      success: (model, response) =>
        @next(response)
      error: @handleError

  countDown: ->
    count = $('[data-behavior=count]').data('count')
    if count > 0
      $('title').html("復習ページ (#{count - 1}) - revenger")
    else
      $('title').html("復習ページ - revenger")
    $('[data-behavior=count]').html(count - 1)
    $('[data-behavior=count]').data('count': count - 1)

  canceUpdateProcess: ->
    update_button = $('[data-behavior="updating"]')
    update_button.replaceWith(JST['posts/update_button']())
