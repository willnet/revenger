require 'spec_helper'

describe :routes do
  context 'GET root_path' do
    subject { {get: root_path } }
    it { should be_routable }
    it { should route_to(controller: 'main', action: 'index') }
  end

  context 'GET help_path' do
    subject { {get: help_path } }
    it { should be_routable }
    it { should route_to(controller: 'main', action: 'help') }
  end

  context "GET user_retire_path" do
    subject { {get: user_retire_path } }
    it { should be_routable }
    it { should route_to(controller: 'users', action: 'retire') }
  end
end
