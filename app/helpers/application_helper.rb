# -*- coding: utf-8 -*-
module ApplicationHelper
  def title(name)
    content_for :title, name
  end

  def javascript(&block)
    content_for :javascript do
      javascript_tag do
        block.call
      end
    end
  end

  def flash_messages
    rv = ''
    flash.each do |name, msg|
      klass = case name
              when :notice
                'alert alert-success fade in flash'
              when :alert
                'alert alert-error fade in flash'
              else
                'alert alert-info fade in flash'
              end
      rv << content_tag(:div, id: 'flash', class: klass) do
        "<div class='container'><a href='#' class='close' data-dismiss='alert' data-target='.alert.flash'>&times;</a>#{msg}</div>".html_safe
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
