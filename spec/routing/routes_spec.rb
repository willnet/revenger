require 'spec_helper'

describe :routes do
  context 'GET root_path' do
    subject { {get: root_path } }
    it { is_expected.to be_routable }
    it { is_expected.to route_to(controller: 'main', action: 'index') }
  end

  context 'GET help_path' do
    subject { {get: help_path } }
    it { is_expected.to be_routable }
    it { is_expected.to route_to(controller: 'main', action: 'help') }
  end

  context "GET user_retire_path" do
    subject { {get: user_retire_path } }
    it { is_expected.to be_routable }
    it { is_expected.to route_to(controller: 'users', action: 'retire') }
  end
end
