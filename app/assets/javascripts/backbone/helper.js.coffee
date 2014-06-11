HAML.globals = ->
  {
    duration_button: (post, value, text) ->
      if post.get('duration') is value
        "<button type='button' class='btn btn-small active' data-value='#{value}'>#{text}</button>"
      else
        "<button type='button' class='btn btn-small' data-value='#{value}'>#{text}</button>"
  }