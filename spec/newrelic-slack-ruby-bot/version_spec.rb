# frozen_string_literal: true

require 'spec_helper'

describe NewRelic::Agent::Instrumentation::SlackRubyBot do
  it 'has a version' do
    expect(NewRelic::Agent::Instrumentation::SlackRubyBot::VERSION).not_to be_nil
  end
end
