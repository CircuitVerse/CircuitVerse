# frozen_string_literal: true

module FsmSynthesizer
  class Encoder
    # Binary state encoding
    def self.encode_binary(fsm)
      num_states = fsm.states.size
      raise FsmSynthesizer::EncodingError, 'FSM must have at least one state' if num_states.zero?

      num_bits = Math.log2(num_states).ceil

      encoding = {}
      fsm.states.each_with_index do |state, index|
        bits = if num_bits.zero?
                 []
               else
                 index.to_s(2).rjust(num_bits, '0').chars.map(&:to_i)
               end
        encoding[state[:id]] = bits
      end

      fsm.state_encoding = encoding
      fsm.state_bits = num_bits

      encoding
    end

    # One-hot encoding (stretch feature)
    def self.encode_one_hot(fsm)
      num_states = fsm.states.size
      raise FsmSynthesizer::EncodingError, 'FSM must have at least one state' if num_states.zero?

      encoding = {}

      fsm.states.each_with_index do |state, index|
        bits = Array.new(num_states, 0)
        bits[index] = 1
        encoding[state[:id]] = bits
      end

      fsm.state_encoding = encoding
      fsm.state_bits = num_states

      encoding
    end
  end
end
