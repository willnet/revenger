object @post

return unless root_object

attributes :id, :body, :duration

node(:markdown) { |post| markdown(post.body) }
node(:created_at) { |post| post.created_at.strftime('%Y/%m/%d %H:%M') }
node(:updated_at) { |post| post.updated_at.strftime('%Y/%m/%d %H:%M') }

