require 'spec_helper'
Fabrication::Support.find_definitions
describe 'Fabricate', solr: true do
  Fabrication.schematics.schematics.keys.each do |name|
    describe "(:#{name})" do
      it { Fabricate(name).should be_valid }
    end
  end
end

