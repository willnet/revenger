require 'spec_helper'
Fabrication::Support.find_definitions
describe 'Fabricate', solr: true do
  Fabrication.schematics.schematics.keys.each do |name|
    describe "(:#{name})" do
      it { expect(Fabricate(name)).to be_valid }
    end
  end
end

