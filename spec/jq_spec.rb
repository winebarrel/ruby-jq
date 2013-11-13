require 'spec_helper'

describe JQ do
  it 'int' do
    expect(JQ('1').search('.')).to eq([1])

    JQ('1').search('.') do |value|
      expect(value).to eq(1)
    end
  end

  it 'float' do
    expect(JQ('1.2').search('.')).to eq([1.2])

    JQ('1.2').search('.') do |value|
      expect(value).to eq(1.2)
    end
  end

  it 'string' do
    expect(JQ('"Zzz"').search('.')).to eq(["Zzz"])

    JQ('"Zzz"').search('.') do |value|
      expect(value).to eq("Zzz")
    end
  end

  it 'array' do
    expect(JQ('[1, "2", 3]').search('.')).to eq([[1, "2", 3]])

    JQ('[1, "2", 3]').search('.') do |value|
      expect(value).to eq([1, "2", 3])
    end
  end

  it 'hash' do
    expect(JQ('{"foo":100, "bar":"zoo"}').search('.')).to eq([{"foo" => 100, "bar" => "zoo"}])

    JQ('{"foo":100, "bar":"zoo"}').search('.') do |value|
      expect(value).to eq({"foo" => 100, "bar" => "zoo"})
    end
  end
end
