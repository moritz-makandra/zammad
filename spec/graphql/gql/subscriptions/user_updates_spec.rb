# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe Gql::Subscriptions::UserUpdates, type: :graphql do

  let(:subscription) do
    read_graphql_file('shared/graphql/subscriptions/userUpdates.graphql') +
      read_graphql_file('shared/graphql/fragments/objectAttributeValues.graphql')
  end
  let(:mock_channel) { build_mock_channel }
  let(:target)       { create(:user) }
  let(:variables)    { { userId: Gql::ZammadSchema.id_from_object(target) } }

  before do
    graphql_execute(subscription, variables: variables, context: { channel: mock_channel })
  end

  context 'with authenticated user', authenticated_as: :agent do
    let(:agent) { create(:agent) }

    it 'subscribes' do
      expect(graphql_response['data']['userUpdates']).to eq({ 'user' => nil })
    end

    it 'receives user updates for target user' do
      target.save!
      expect(mock_channel.mock_broadcasted_messages.first[:result]['data']['userUpdates']['user']['firstname']).to eq(target.firstname)
    end

    it 'does not receive user updates for other users' do
      create(:agent).save!
      expect(mock_channel.mock_broadcasted_messages).to be_empty
    end
  end

  context 'with authenticated customer', authenticated_as: :customer do
    let(:customer) { create(:customer) }

    context 'when subscribing for other users' do
      it 'does not subscribe' do
        expect(graphql_response['errors'][0]).to be_present
      end

      it 'returns an authorization error' do
        expect(graphql_response['errors'][0]['extensions']['type']).to eq('Exceptions::Forbidden')
      end
    end

    context 'when subscribing for itself' do
      let(:target) { customer }

      it 'subscribes' do
        expect(graphql_response['data']['userUpdates']).to eq({ 'user' => nil })
      end

      it 'receives user updates for target user' do
        target.save!
        expect(mock_channel.mock_broadcasted_messages.first[:result]['data']['userUpdates']['user']['firstname']).to eq(target.firstname)
      end

      it 'does not receive user updates for other users' do
        create(:agent).save!
        expect(mock_channel.mock_broadcasted_messages).to be_empty
      end
    end
  end

  it_behaves_like 'graphql responds with error if unauthenticated'
end
