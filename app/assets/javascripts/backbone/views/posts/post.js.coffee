class Revenger.Views.Post extends Backbone.View
  className: 'post'

  initialize: ->
    @model.on('update', @render, this)
    @model.on('destroy', @remove, this)

  events:
    'click [data-behavior=edit]': 'visibleEdit'
    'click [data-behavior=cancel]': 'invisibleEdit'
    'click [data-behavior=destroy]': 'destroy'
    'click [data-behavior=update]': 'update'

  template: JST['posts/post']

  render: ->
    @$el.html(@template(post: @model))
    this

  visibleEdit: (event) ->
    event.preventDefault()
    @$el.find('[data-behavior=view-element]').hide()
    @$el.find('[data-behavior=edit-element]').show()

  invisibleEdit: (event) ->
    event.preventDefault()
    @$el.find('[data-behavior=view-element]').show()
    @$el.find('[data-behavior=edit-element]').hide()

  destroy: (event) ->
    event.preventDefault()
    return unless confirm '本当に削除して宜しいですか？'
    destroy_btn = @$el.find('[data-behavior=destroy]')
    Revenger.Views.Helper.process_button(destroy_btn)
    @model.destroy success: (model, response) ->
      model.trigger('destroy')

  update: (event) ->
    event.preventDefault()
    @$el.find('[data-behavior=update]').
      replaceWith(JST['posts/updating_button']())
    duration = @$el.find('[data-behavior=duration]').find('button.active').data('value')
    body = @$el.find('[data-behavior=body]').val()
    @model.save { duration: duration, body: body },
      success: (model, response) ->
        model.trigger('update')
      error: (model, response) =>
        @handleError(response)
        @canceUpdateProcess()

  handleError: (response) ->
    if response.status is 422
      errors = $.parseJSON(response.responseText).errors
      str = ''
      for attribute, messages of errors
        str += "#{I18n.t(attribute, {scope: 'activerecord.attributes.post'})}#{message}" for message in messages
      alert str

  canceUpdateProcess: ->
    update_button = $('[data-behavior="updating"]')
    update_button.replaceWith(JST['posts/update_button']())
