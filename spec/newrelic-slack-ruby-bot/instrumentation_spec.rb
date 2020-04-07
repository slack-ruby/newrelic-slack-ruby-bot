# frozen_string_literal: true

require 'spec_helper'

describe NewRelic::Agent::Instrumentation do
  subject { SlackRubyBot::Hooks::Message.new }
  let(:client) { SlackRubyBot::Client.new }
  before(:all) { SlackRubyBot::Config.user = 'mybot' }

  it 'perform_action_with_newrelic_trace' do
    expect(subject)
      .to receive(:perform_action_with_newrelic_trace)
      .with(hash_including(name: 'call', category: 'OtherTransaction/Slack'))
      .and_yield

    subject.call(
      client,
      Slack::Messages::Message.new(
        message: 'message',
        text: 'hi',
        team: 'TEAM',
        channel: 'CHANNEL',
        user: 'USER'
      )
    )
  end

  context 'operator' do
    before(:all) do
      MyOperatorClass = Class.new(SlackRubyBot::Commands::Base) do
        operator('+') { |_client, _data, _match| }
      end
    end
    it 'adds team, channel, user, and match attributes' do
      expect(::NewRelic::Agent)
        .to receive(:add_custom_attributes)
        .with(hash_including(team: 'TEAM', channel: 'CHANNEL', user: 'USER'))
      expect(::NewRelic::Agent)
        .to receive(:add_custom_attributes)
        .with(hash_including(operator: '+', expression: '42'))

      subject.call(
        client,
        Slack::Messages::Message.new(
          message: 'message',
          text: '+42',
          team: 'TEAM',
          channel: 'CHANNEL',
          user: 'USER'
        )
      )
    end
    it 'sets transaction name' do
      expect(::NewRelic::Agent).to receive(:set_transaction_name).with('MyOperatorClass/+')

      subject.call(
        client,
        Slack::Messages::Message.new(
          message: 'message',
          text: '+42',
          team: 'TEAM',
          channel: 'CHANNEL',
          user: 'USER'
        )
      )
    end
  end

  context 'command' do
    before(:all) do
      MyCommandClass = Class.new(SlackRubyBot::Commands::Base) do
        command('this') { |_client, _data, _match| }
      end
    end
    it 'adds team, channel, user, and match attributes' do
      expect(::NewRelic::Agent)
        .to receive(:add_custom_attributes)
        .with(hash_including(team: 'TEAM', channel: 'CHANNEL', user: 'USER'))
      expect(::NewRelic::Agent)
        .to receive(:add_custom_attributes)
        .with(hash_including(bot: 'mybot', command: 'this', expression: 'is the command'))

      subject.call(
        client,
        Slack::Messages::Message.new(
          message: 'message',
          text: "#{client.name} this is the command",
          team: 'TEAM',
          channel: 'CHANNEL',
          user: 'USER'
        )
      )
    end
    it 'sets transaction name' do
      expect(::NewRelic::Agent).to receive(:set_transaction_name).with('MyCommandClass/this')

      subject.call(
        client,
        Slack::Messages::Message.new(
          message: 'message',
          text: "#{client.name} this is the command",
          team: 'TEAM',
          channel: 'CHANNEL',
          user: 'USER'
        )
      )
    end
  end

  context 'match' do
    before(:all) do
      MyMatchClass = Class.new(SlackRubyBot::Commands::Base) do
        match('read this') { |_client, _data, _match| }
      end
    end
    it 'adds team, channel, user, and match attributes' do
      expect(::NewRelic::Agent)
        .to receive(:add_custom_attributes)
        .with(hash_including(team: 'TEAM', channel: 'CHANNEL', user: 'USER'))
      expect(::NewRelic::Agent).to receive(:add_custom_attributes).with({})

      subject.call(client, Slack::Messages::Message.new(
                             message: 'message',
                             text: 'read this',
                             team: 'TEAM',
                             channel: 'CHANNEL',
                             user: 'USER'
                           ))
    end
    it 'sets transaction name' do
      expect(::NewRelic::Agent).to receive(:set_transaction_name).with('MyMatchClass/match')

      subject.call(client, Slack::Messages::Message.new(
                             message: 'message',
                             text: 'read this',
                             team: 'TEAM',
                             channel: 'CHANNEL',
                             user: 'USER'
                           ))
    end
  end

  context 'scan' do
    before(:all) do
      MyScanClass = Class.new(SlackRubyBot::Commands::Base) do
        scan('scanned') { |_client, _data, _match| }
      end
    end
    it 'adds team, channel, user, and match attributes' do
      expect(::NewRelic::Agent)
        .to receive(:add_custom_attributes)
        .with(hash_including(team: 'TEAM', channel: 'CHANNEL', user: 'USER'))
      expect(::NewRelic::Agent).not_to receive(:add_custom_attributes)

      subject.call(client, Slack::Messages::Message.new(
                             message: 'message',
                             text: 'I scanned this',
                             team: 'TEAM',
                             channel: 'CHANNEL',
                             user: 'USER'
                           ))
    end
    it 'sets transaction name' do
      expect(::NewRelic::Agent).to receive(:set_transaction_name).with('MyScanClass/scan')

      subject.call(client, Slack::Messages::Message.new(
                             message: 'message',
                             text: 'I scanned this',
                             team: 'TEAM',
                             channel: 'CHANNEL',
                             user: 'USER'
                           ))
    end
  end
end
