# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe Gql::Subscriptions::PushMessages, type: :graphql do

  let(:subscription) { read_graphql_file('shared/graphql/subscriptions/pushMessages.graphql') }
  let(:mock_channel) { build_mock_channel }
  let(:expected_msg) do
    {
      result: {
        'data' => {
          'pushMessages' => {
            'title' => 'Attention',
            'text'  => 'Maintenance test message.',
          }
        }
      },
      more:   true,
    }
  end

  def trigger_push_message(title, text)
    Gql::ZammadSchema.subscriptions.trigger(
      described_class.field_name,
      {},
      {
        title: title,
        text:  text,
      }
    )
  end

  before do
    graphql_execute(subscription, context: { channel: mock_channel })
  end

  it 'broadcasts push message to all users' do
    trigger_push_message('Attention', 'Maintenance test message.')
    expect(mock_channel.mock_broadcasted_messages).to eq([expected_msg])
  end
end
