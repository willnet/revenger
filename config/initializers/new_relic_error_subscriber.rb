class NewRelicErrorSubscriber
  def report(error, severity:, source:, **)
    NewRelic::Agent.notice_error(
      error,
      expected: severity != :error,
      custom_params: { severity:, source: }
    )
  end
end

Rails.error.subscribe(NewRelicErrorSubscriber.new) if Rails.env.production?
