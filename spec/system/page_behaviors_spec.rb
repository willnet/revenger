require 'spec_helper'

describe '画面遷移後の操作' do
  let(:user) { Fabricate(:user) }

  before do
    sign_in(user.email, user.password)
  end

  it '画面遷移で表示された通知を閉じられること' do
    find('[aria-label="通知を閉じる"]').click
    expect(page).to have_no_css('.flash')

    within '.navbar' do
      click_link '新規作成', exact: true
    end
    fill_in 'post_body', with: '新しいメモ'
    click_button 'create!'
    expect(page).to have_css('.alert-success.flash', text: '作成しました')
    find('[aria-label="通知を閉じる"]').click
    expect(page).to have_no_css('.flash')
  end

  it '成功通知は時間が経つと閉じること' do
    expect(page).to have_css('.alert-success.flash', text: 'ログインしました')
    expect(page).to have_no_css('.flash', wait: 7)
  end

  it '通常のリンク遷移ではページ全体をリロードしないこと' do
    visit posts_path
    page.execute_script('window.navigationMarker = "preserved"')
    click_link '利用規約', exact: true
    expect(page).to have_current_path terms_path
    expect(page).to have_css('body.main_controller.terms_action')
    expect(page.evaluate_script('window.navigationMarker')).to eq 'preserved'
  end

  it 'エラー通知を閉じられること' do
    visit user_retire_path
    fill_in 'パスワード', with: 'wrong-password'
    accept_confirm { click_button '退会する' }
    expect(page).to have_css('.alert-error.flash', text: 'パスワードが間違っています')
    find('[aria-label="通知を閉じる"]').click
    expect(page).to have_no_css('.flash')
  end

  it '設定メニューを開閉し、画面遷移後も操作できること' do
    find('[data-dropdown-target="toggle"]').click
    expect(page).to have_css('.dropdown.open .dropdown-menu')
    expect(page).to have_css('[data-dropdown-target="toggle"][aria-expanded="true"]')
    find('body').send_keys :escape
    expect(page).to have_no_css('.dropdown.open')

    find('[data-dropdown-target="toggle"]').click
    click_link 'デフォルト復習間隔', exact: true
    expect(page).to have_current_path edit_duration_path
    expect(page).to have_no_css('.dropdown.open')

    find('[data-dropdown-target="toggle"]').click
    expect(page).to have_css('.dropdown.open .dropdown-menu')
    find('.top-container').click
    expect(page).to have_no_css('.dropdown.open')
    expect(page).to have_css('[data-dropdown-target="toggle"][aria-expanded="false"]')
  end

  it 'ヘルプの目次がスクロールに追従し、再訪問時に初期化されること' do
    click_link 'ヘルプ', exact: true
    expect(page).to have_css('.nav-list li.active a[href="#revenger"]')
    expect(page).to have_no_css('[data-scrollspy-target="navigation"].affix')

    page.execute_script("document.getElementById('duration').scrollIntoView()")
    expect(page).to have_css('[data-scrollspy-target="navigation"].affix')
    expect(page).to have_css('.nav-list li.active a[href="#duration"]')

    click_link '一覧', exact: true
    expect(page).to have_current_path posts_path
    click_link 'ヘルプ', exact: true
    expect(page).to have_css('.nav-list li.active a[href="#revenger"]')
    expect(page).to have_no_css('[data-scrollspy-target="navigation"].affix')
  end
end
