# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  hatena_key             :string(255)      not null
#  default_duration       :integer          default(1)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  receive_reminder       :boolean          default(TRUE)
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :recoverable, :registerable, :rememberable, :trackable, :validatable
  has_many :posts, :dependent => :destroy
  has_many :reviewable_posts, -> {
    where('review_at < ?', Time.zone.now)
  }, class_name: 'Post'

  validates :agree, :acceptance => true, :on => :create

  before_create :set_hatena_key
  before_create :build_initial_posts

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }

  def set_hatena_key
    generate_token(:hatena_key)
  end

  def build_initial_posts
    first_post_body =<<-"EOS"
# revenger の使い方

revenger に登録いただきありがとうございます！

ここはレビューページです。あなたが書いたを復習メモを読みなおすページになります。

## revenger の基本的な使い方

まずは[新規作成](https://revenger.in/posts/new)ページで復習メモを作成します。すると一定期間後にレビューページに復習メモが現れるので、読み直して記憶に定着させてください。修正や追記がしたくなったら右上の「edit」ボタンを押すと編集できるようになります。手直ししたら「update!」を押して保存しましょう。

満足したら左上の「read it!」ボタンを押してください。次の復習メモが現れます。その調子でひたすら復習していきましょう。

## 復習間隔の変更

画面上部のボタン群で、次に復習する日を設定できます。今は「1 day」が選択されているはずです。他の日付のボタンを選択し、「read it!」(もしくは「update!」)ボタンを押すと、設定が保存されます。「no more」はもう復習する必要は無いよ！という意味です。

## デフォルト復習間隔

新しく作成された復習メモは、デフォルトではすべて一日後に復習する設定になっています。変更は、[デフォルト復習間隔](https://revenger.in/user/duration/edit)のページで可能です。

EOS

    second_post_body =<<-"EOS"
# markdown の書き方

revenger の復習メモは [markdown](http://ja.wikipedia.org/wiki/Markdown) 形式で書くことができます。右上の edit ボタンを押すと、今見ているこの文章を、markdown 形式でどのように表しているか確認することができます。復習メモを書くときに参考にしてください。

## 書き方例

### リンク

[revengerへのリンク](https://revenger.in/)

### 画像

![star](https://revenger.in/star.png)

### 箇条書き

* 肉
* 野菜
* 果物
  * リンゴ
  * オレンジ
  * ぶどう

1. 起きる
2. 食べる
3. 寝る

### 水平線

---

### 文字の装飾

*斜体*
**太字**

### 引用

> これは引用文です！

### コード

`puts 'hoge'` のような形で文中にコードを書くことが出来ます。下記のように書くと言語毎のシンタックスハイライトを適用させることが出来ます。

```ruby
puts 'hello world'
```
EOS

    posts.build(body: first_post_body, review_at: Time.zone.now, modified_at: Time.zone.now)
    posts.build(body: second_post_body, review_at: Time.zone.now, modified_at: Time.zone.now)
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while self.class.exists?(column => self[column])
  end
end
