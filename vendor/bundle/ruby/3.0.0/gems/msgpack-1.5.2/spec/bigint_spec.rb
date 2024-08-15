require 'spec_helper'

describe MessagePack::Bigint do
  it 'serialize and deserialize arbitrary sized integer' do
    [
      1,
      -1,
      120938120391283122132313,
      -21903120391203912391023920332103,
      210290021321301203912933021323,
    ].each do |int|
      expect(MessagePack::Bigint.from_msgpack_ext(MessagePack::Bigint.to_msgpack_ext(int))).to be == int
    end
  end

  it 'has a stable format' do
    {
      120938120391283122132313 => "\x00\x9F\xF4UY\x11\x92\x9A?\x00\x00\x19\x9C".b,
      -21903120391203912391023920332103 => "\x01/\xB2\xBDG\xBD\xDE\xAA\xEBt\xCC\x8A\xC1\x00\x00\x01\x14".b,
      210290021321301203912933021323 => "\x00\xC4\xD8\x96\x8Bm\xCB\xC7\x03\xA7{\xD4\"\x00\x00\x00\x02".b,
    }.each do |int, payload|
      expect(MessagePack::Bigint.to_msgpack_ext(int)).to be == payload
      expect(MessagePack::Bigint.from_msgpack_ext(payload)).to be == int
    end
  end
end
