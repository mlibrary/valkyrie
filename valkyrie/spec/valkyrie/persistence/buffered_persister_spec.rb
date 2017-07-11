# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::BufferedPersister do
  let(:persister) do
    described_class.new(
      Valkyrie::Persistence::Memory::Adapter.new.persister
    )
  end
  before do
    class Resource < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title
      attribute :member_ids
      attribute :nested_resource
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  it_behaves_like "a Valkyrie::Persister"
  describe "#with_buffer" do
    it "can buffer a session into a memory adapter" do
      buffer = nil
      persister.with_buffer do |persister, memory_buffer|
        persister.save(model: Resource.new)
        buffer = memory_buffer
      end
      expect(buffer.query_service.find_all.length).to eq 1
    end
  end
end