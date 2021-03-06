require 'kanren/micro/goal'
require 'kanren/micro/relations'
require 'kanren/micro/state'
require 'kanren/peano'

module Kanren
  module Micro
    module Data
      RSpec.describe 'relations on numbers' do
        describe 'addition' do
          it 'adds two numbers' do
            goal = Goal.with_variables { |x|
              Relations.add(Peano.from_integer(5), Peano.from_integer(3), x)
            }
            states = goal.pursue_in(State.new)

            results = states.map { |state| Peano.to_integer(state.result) }
            expect(results).to eq [8]
          end

          it 'subtracts two numbers' do
            goal = Goal.with_variables { |x|
              Relations.add(x, Peano.from_integer(3), Peano.from_integer(8))
            }
            states = goal.pursue_in(State.new)

            results = states.map { |state| Peano.to_integer(state.result) }
            expect(results).to eq [5]
          end

          it 'finds all pairs of numbers which are equal to another when added' do
            goal = Goal.with_variables { |x, y|
              Relations.add(x, y, Peano.from_integer(8))
            }
            states = goal.pursue_in(State.new)

            results = states.map { |state| state.results(2).map(&Peano.method(:to_integer)) }
            expect(results).to eq [
              [0, 8],
              [1, 7],
              [2, 6],
              [3, 5],
              [4, 4],
              [5, 3],
              [6, 2],
              [7, 1],
              [8, 0]
            ]
          end
        end

        describe 'multiplication' do
          it 'mutiplies two numbers' do
            goal = Goal.with_variables { |x|
              Relations.multiply(Peano.from_integer(3), Peano.from_integer(8), x)
            }
            states = goal.pursue_in(State.new)

            results = states.take(1).map { |state| Peano.to_integer(state.result) }
            expect(results).to eq [24]
          end

          it 'finds all pairs of numbers which are equal to another when multiplied' do
            goal = Goal.with_variables { |x, y|
              Relations.multiply(x, y, Peano.from_integer(24))
            }
            states = goal.pursue_in(State.new)

            results = states.take(8).map { |state| state.results(2).map(&Peano.method(:to_integer)) }
            expect(results).to eq [
              [1, 24],
              [2, 12],
              [3, 8],
              [4, 6],
              [6, 4],
              [8, 3],
              [12, 2],
              [24, 1]
            ]
          end
        end
      end
    end
  end
end
