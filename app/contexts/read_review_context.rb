class ReadReviewContext
  def initialize(user, params)
    @user = user
    @params = params
  end

  def self.call(user, params)
    new(user, params).call
  end

  def call
    reviewing = @user.posts.find(@params[:review][:post_id])
    # 復習間隔の選択肢にない値のメモはどれも選択されずに送信されるため、未送信なら現在の間隔を維持する。
    reviewing.duration = @params[:review][:duration] if @params[:review].key?(:duration)
    reviewing.refresh_review_at
    reviewing.save!
  end
end
