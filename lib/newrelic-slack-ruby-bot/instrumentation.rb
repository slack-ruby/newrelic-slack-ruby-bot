# frozen_string_literal: true

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
  end

  executes do
    ::SlackRubyBot::Hooks::Message.class_eval do
      include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

      def message_with_new_relic(client, data)
        perform_action_with_newrelic_trace(name: 'call', category: 'OtherTransaction/Slack') do
          ::NewRelic::Agent.add_custom_attributes(
            team: data.team,
            channel: data.channel,
            user: data.user
          )
          message_without_new_relic(client, data)
        end
      end

      alias_method :message_without_new_relic, :call
      alias_method :call, :message_with_new_relic
    end
  end

  executes do
    ::SlackRubyBot::Commands::Base.class_eval do
      class << self
        def command_name(match)
          if match.respond_to?(:names) && match.respond_to?(:[])
            if match.names.include? 'command'
              match[:command].downcase
            elsif match.names.include? 'operator'
              match[:operator].downcase
            else
              'match'
            end
          else
            'scan'
          end
        end

        def call_command_with_new_relic(client, data, match, block)
          ::NewRelic::Agent.set_transaction_name("#{self}/#{command_name(match)}")
          if match.respond_to?(:names) && match.respond_to?(:captures)
            ::NewRelic::Agent
              .add_custom_attributes(
                Hash[match.names.map(&:to_sym).zip(match.captures)]
              )
          end
          call_command_without_new_relic(client, data, match, block)
        end

        alias_method :call_command_without_new_relic, :call_command
        alias_method :call_command, :call_command_with_new_relic
      end
    end
  end
end
