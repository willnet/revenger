require 'spec_helper'

describe 'Turnstile の読み込み' do
  it '登録画面でだけ Turnstile のスクリプトを読み込むこと' do
    get signup_path
    document = Nokogiri::HTML5(response.body)
    expect(document.css('script[src*="turnstile"]').size).to eq 1

    get login_path
    document = Nokogiri::HTML5(response.body)
    expect(document.css('script[src*="turnstile"]')).to be_empty
  end
end
