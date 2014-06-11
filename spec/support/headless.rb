if %w(yes y on).include?(ENV['HEADLESS'])
  require 'headless'

  headless = Headless.new
  headless.start

  at_exit do
    headless.destroy
  end
end
