RSpec::Matchers.define :have_bodies do |bodies|
  match do |page|
    page_bodies = page.all('.post .body').map { |body| body.text.gsub(/\s/, "") }
    page_bodies.each_with_index.all? do |page_body, i|
      page_body =~ /#{bodies[i]}/
    end
  end

  failure_message_for_should do |page|
    "expected page have bodies #{bodies} but #{page.all('.post .body').map { |body| body.text.gsub(/\s/, "") }.inspect}"
  end

  failure_message_for_should_not do |employee|
    "expected the team run by #{boss} to exclude #{employee}"
  end
end

RSpec::Matchers.define :be_the_same_time_as do |other|
  match do |time|
    time.to_i == other.to_i
  end
end
