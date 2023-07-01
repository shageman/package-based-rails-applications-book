# frozen_string_literal: true

RSpec.describe Testgem::Sample do
  it 'returns 3 when tested' do
    expect(subject.test).to eq(3)
  end
end

