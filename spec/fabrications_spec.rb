require 'spec_helper'
Fabrication.manager.load_definitions
describe 'Fabricate', solr: true do
  Fabrication.manager.schematics.keys.each do |name|
    describe "(:#{name})" do
      it { expect(Fabricate(name)).to be_valid }
    end
  end
end
