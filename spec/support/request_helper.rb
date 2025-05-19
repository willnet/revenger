def set_subdomain(subdomain)
  Capybara.default_host = "#{subdomain}.example.com" # for Rack::Test
  Capybara.app_host = "http://#{subdomain}.revenger.te:3000" # for another drivers
  I18n.locale = subdomain
end

def sign_in(email, password)
  visit login_path
  fill_in "user_email", with: email
  fill_in "user_password", with: password
  click_button 'ログイン'
end
