require 'kanren/utils'

module Kanren
  module Micro
    class Goal
      def initialize(&block)
        @block = block
      end

      def pursue_in(state)
        @block.call state
      end

      def pursue_in_each(states)
        Enumerator.new do |yielder|
          results = pursue_in(states.next)
          results = Utils.interleave(results, pursue_in_each(states))

          results.each do |state|
            yielder.yield state
          end
        end
      end

      def self.equal(a, b)
        new do |state|
          state = state.unify(a, b)

          Enumerator.new do |yielder|
            yielder.yield state if state
          end
        end
      end

      def self.with_variables(&block)
        names = block.parameters.map { |type, name| name }

        new do |state|
          state, variables = state.create_variables(names)
          goal = block.call(*variables)
          goal.pursue_in state
        end
      end

      def self.any(*goals)
        new do |state|
          streams = goals.map { |goal| goal.pursue_in(state) }

          Utils.interleave(*streams)
        end
      end

      class << self
        alias_method :both, :any
      end

      def self.both(first_goal, second_goal)
        new do |state|
          states = first_goal.pursue_in(state)
          second_goal.pursue_in_each states
        end
      end
    end
  end
end
