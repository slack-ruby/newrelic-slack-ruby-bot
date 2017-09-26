DependencyDetection.defer do
  named :slack_ruby_bot

  depends_on do
    !::NewRelic::Agent.config[:disable_slack_ruby_bot]
  end

  depends_on do
    defined?(::SlackRubyBot::VERSION)
  end

  executes do
    NewRelic::Agent.logger.info 'Installing SlackRubyBot instrumentation'
    instrument_call
  end

  def instrument_call
    ::SlackRubyBot::Server.class_eval do
      include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

      def message_with_new_relic(client, data)
        perform_action_with_newrelic_trace(name: 'message', category: 'OtherTransaction/Slack') do
          message_without_new_relic(client, data)
        end
      end

      alias_method :message_without_new_relic, :message
      alias_method :message, :message_with_new_relic
    end
  end
end
