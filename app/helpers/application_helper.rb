module ApplicationHelper
  def icon(name)
    content_tag(:svg, class: "app-icon app-icon-#{name}", 'aria-hidden': true, focusable: false) do
      tag.use(href: "#icon-#{name}")
    end
  end

  def title(name)
    content_for :title, name
  end

  def flash_messages
    rv = ''
    flash.each do |name, msg|
      klass = case name.to_sym
              when :notice
                'alert alert-success fade in flash'
              when :alert
                'alert alert-error fade in flash'
              else
                'alert alert-info fade in flash'
              end
      data = { controller: 'alert', turbo_temporary: true }
      data[:alert_dismiss_after_value] = 5000 if name.to_sym == :notice
      rv << content_tag(:div, id: 'flash', class: klass, data: data) do
        "<div class='container'><a href='#' class='close' aria-label='通知を閉じる' data-action='alert#close:prevent'>&times;</a>#{msg}</div>".html_safe
      end
    end
    rv.html_safe
  end

  def markdown(text)
    rndr = HtmlWithPygments.new(filter_html: true, hard_wrap: true)
    md = Redcarpet::Markdown.new(rndr, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, space_after_headers: true)
    md.render(text).html_safe
  end

  def post_info(post)
    '作成:' + post.created_at.strftime('%Y年%m月%d日%H時%M分') + ' 更新:' + post.modified_at.strftime('%Y年%m月%d日%H時%M分')
  end
end
