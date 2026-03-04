# State Encoding Service
module FsmSynthesizer
  class Encoder
    # Binary state encoding
    def self.encode_binary(fsm)
      num_states = fsm.states.size
      num_bits = Math.log2(num_states).ceil

      encoding = {}
      fsm.states.each_with_index do |state, index|
        bits = index.to_s(2).rjust(num_bits, '0').split('').map(&:to_i)
        encoding[state[:id]] = bits
      end

      fsm.state_encoding = encoding
      fsm.state_bits = num_bits

      encoding
    end

    # One-hot encoding (stretch feature)
    def self.encode_one_hot(fsm)
      num_states = fsm.states.size
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
