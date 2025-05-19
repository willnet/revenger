require 'spec_helper'

describe 'mail:assignment' do
  include_context 'rake'

  its(:prerequisites) { should include("environment") }

  it "SendAssignmentMailContext.call を呼び出していること" do
    expect(SendAssignmentMailContext).to receive(:call)
    subject.invoke
  end
end
