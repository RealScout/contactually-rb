require 'spec_helper'

describe Contactually::Interactions do
  describe '#model' do
    it 'returns the Interaction class' do
      expect(described_class.new.model).to eq(Contactually::Models::Interaction)
    end
  end

  describe '.implements' do
    it 'implements fetch endpoint functionality' do
      client = build_client
      stub_request(:get, 'https://api.contactually.com/v2/interactions/interaction_1').
        to_return(body: MockResponses::Interactions.fetch_response, headers: {'Content-Type' => 'application/json'})

      response = client.interactions.fetch('interaction_1')

      expect(response.raw_response.body).to eq(JSON.parse(MockResponses::Interactions.fetch_response))
      expect(response.data).to be_a(Contactually::Models::Interaction)
    end

    it 'implements update endpoint functionality' do
      client = build_client
      stub_request(:patch, 'https://api.contactually.com/v2/interactions/interaction_1').
        to_return(body: MockResponses::Interactions.update_response, headers: {'Content-Type' => 'application/json'})

      response = client.interactions.update('interaction_1', {})

      expect(response.raw_response.body).to eq(JSON.parse(MockResponses::Interactions.update_response))
      expect(response.data).to be_a(Contactually::Models::Interaction)
    end
  end
end