RSpec.describe 'rubocop-packs validations' do
  it { expect(RuboCop::Packs.validate).to be_empty }
end
