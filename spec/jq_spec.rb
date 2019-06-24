# frozen_string_literal: true

describe JQ do
  specify 'int' do
    expect(JQ('1').search('.')).to eq([1])

    JQ('1').search('.') do |value|
      expect(value).to eq(1)
    end
  end

  specify 'float' do
    expect(JQ('1.2').search('.')).to eq([1.2])

    JQ('1.2').search('.') do |value|
      expect(value).to eq(1.2)
    end
  end

  specify 'string' do
    expect(JQ('"Zzz"').search('.')).to eq(['Zzz'])

    JQ('"Zzz"').search('.') do |value|
      expect(value).to eq('Zzz')
    end
  end

  specify 'array' do
    expect(JQ('[1, "2", 3]').search('.')).to eq([[1, '2', 3]])

    JQ('[1, "2", 3]').search('.') do |value|
      expect(value).to eq([1, '2', 3])
    end
  end

  specify 'hash' do
    expect(JQ('{"foo":100, "bar":"zoo"}').search('.')).to eq([{ 'foo' => 100, 'bar' => 'zoo' }])

    JQ('{"foo":100, "bar":"zoo"}').search('.') do |value|
      expect(value).to eq('foo' => 100, 'bar' => 'zoo')
    end
  end

  specify 'composition' do
    src = <<~JSON
      {
          "glossary": {
              "title": "example glossary",
          "GlossDiv": {
                  "title": "S",
            "GlossList": {
                      "GlossEntry": {
                          "ID": "SGML",
                "SortAs": "SGML",
                "GlossTerm": "Standard Generalized Markup Language",
                "Acronym": "SGML",
                "Abbrev": "ISO 8879:1986",
                "GlossDef": {
                              "para": "A meta-markup language, used to create markup languages such as DocBook.",
                  "GlossSeeAlso": ["GML", "XML"]
                          },
                "GlossSee": "markup"
                      }
                  }
              }
          }
      }
    JSON

    expected = {
      'glossary' =>
        { 'GlossDiv' =>
          { 'GlossList' =>
            { 'GlossEntry' =>
              { 'GlossSee' => 'markup',
                'GlossDef' =>
                { 'GlossSeeAlso' => %w[GML XML],
                  'para' =>
                  'A meta-markup language, used to create markup languages such as DocBook.' },
                'Abbrev' => 'ISO 8879:1986',
                'Acronym' => 'SGML',
                'GlossTerm' => 'Standard Generalized Markup Language',
                'SortAs' => 'SGML',
                'ID' => 'SGML' } },
            'title' => 'S' },
          'title' => 'example glossary' }
    }

    expect(JQ(src).search('.')).to eq([expected])

    JQ(src).search('.') do |value|
      expect(value).to eq(expected)
    end
  end

  specify 'read from file' do
    Tempfile.open("ruby-jq.spec.#{$PROCESS_ID}") do |src|
      src.puts(<<~JSON)
        {
            "glossary": {
                "title": "example glossary",
            "GlossDiv": {
                    "title": "S",
              "GlossList": {
                        "GlossEntry": {
                            "ID": "SGML",
                  "SortAs": "SGML",
                  "GlossTerm": "Standard Generalized Markup Language",
                  "Acronym": "SGML",
                  "Abbrev": "ISO 8879:1986",
                  "GlossDef": {
                                "para": "A meta-markup language, used to create markup languages such as DocBook.",
                    "GlossSeeAlso": ["GML", "XML"]
                            },
                  "GlossSee": "markup"
                        }
                    }
                }
            }
        }
      JSON

      expected = {
        'glossary' =>
          { 'GlossDiv' =>
            { 'GlossList' =>
              { 'GlossEntry' =>
                { 'GlossSee' => 'markup',
                  'GlossDef' =>
                  { 'GlossSeeAlso' => %w[GML XML],
                    'para' =>
                    'A meta-markup language, used to create markup languages such as DocBook.' },
                  'Abbrev' => 'ISO 8879:1986',
                  'Acronym' => 'SGML',
                  'GlossTerm' => 'Standard Generalized Markup Language',
                  'SortAs' => 'SGML',
                  'ID' => 'SGML' } },
              'title' => 'S' },
            'title' => 'example glossary' }
      }

      expect(JQ(src).search('.')).to eq([expected])

      JQ(src).search('.') do |value|
        expect(value).to eq(expected)
      end
    end
  end

  specify 'read from file (> 4096)' do
    Tempfile.open("ruby-jq.spec.#{$PROCESS_ID}") do |src|
      src.puts('[' + (1..10).map { <<~JSON }.join(',') + ']')
        {
            "glossary": {
                "title": "example glossary",
            "GlossDiv": {
                    "title": "S",
              "GlossList": {
                        "GlossEntry": {
                            "ID": "SGML",
                  "SortAs": "SGML",
                  "GlossTerm": "Standard Generalized Markup Language",
                  "Acronym": "SGML",
                  "Abbrev": "ISO 8879:1986",
                  "GlossDef": {
                                "para": "A meta-markup language, used to create markup languages such as DocBook.",
                    "GlossSeeAlso": ["GML", "XML"]
                            },
                  "GlossSee": "markup"
                        }
                    }
                }
            }
        }
      JSON

      expected = (1..10).map do
        {
          'glossary' =>
            { 'GlossDiv' =>
              { 'GlossList' =>
                { 'GlossEntry' =>
                  { 'GlossSee' => 'markup',
                    'GlossDef' =>
                    { 'GlossSeeAlso' => %w[GML XML],
                      'para' =>
                      'A meta-markup language, used to create markup languages such as DocBook.' },
                    'Abbrev' => 'ISO 8879:1986',
                    'Acronym' => 'SGML',
                    'GlossTerm' => 'Standard Generalized Markup Language',
                    'SortAs' => 'SGML',
                    'ID' => 'SGML' } },
                'title' => 'S' },
              'title' => 'example glossary' }
        }
      end

      expect(JQ(src).search('.')).to eq([expected])

      JQ(src).search('.') do |value|
        expect(value).to eq(expected)
      end
    end
  end

  specify 'parse_json => false' do
    src = <<~JSON
      {
          "glossary": {
              "title": "example glossary",
          "GlossDiv": {
                  "title": "S",
            "GlossList": {
                      "GlossEntry": {
                          "ID": "SGML",
                "SortAs": "SGML",
                "GlossTerm": "Standard Generalized Markup Language",
                "Acronym": "SGML",
                "Abbrev": "ISO 8879:1986",
                "GlossDef": {
                              "para": "A meta-markup language, used to create markup languages such as DocBook.",
                  "GlossSeeAlso": ["GML", "XML"]
                          },
                "GlossSee": "markup"
                      }
                  }
              }
          }
      }
    JSON

    expected = '{"glossary":{"GlossDiv":{"GlossList":{"GlossEntry":{"GlossSee":"markup","GlossDef":{"GlossSeeAlso":["GML","XML"],"para":"A meta-markup language, used to create markup languages such as DocBook."},"Abbrev":"ISO 8879:1986","Acronym":"SGML","GlossTerm":"Standard Generalized Markup Language","SortAs":"SGML","ID":"SGML"}},"title":"S"},"title":"example glossary"}}'
    searched = JQ(src, parse_json: false).search('.')

    expect(searched.length).to eq(1)
    expect(searched[0]).to be_kind_of(String)
    expect(MultiJson.load(searched[0])).to eq(MultiJson.load(expected))

    JQ(src, parse_json: false).search('.') do |value|
      expect(value).to be_kind_of(String)
      expect(MultiJson.load(value)).to eq(MultiJson.load(expected))
    end
  end

  specify 'each value' do
    src = <<~JSON
      {"menu": {
        "id": "file",
        "value": "File",
        "popup": {
          "menuitem": [
            {"value": "New", "onclick": "CreateNewDoc()"},
            {"value": "Open", "onclick": "OpenDoc()"},
            {"value": "Close", "onclick": "CloseDoc()"}
          ]
        }
      }}
    JSON

    expect(JQ(src).search('.menu.popup.menuitem[].value')).to eq(%w[New Open Close])
  end

  specify 'compile error' do
    expect do
      JQ('{}').search('...')
    end.to raise_error(JQ::Error).with_message(<<~ERRMSG.chomp)
      jq: 1 compile error
      jq: error: Invalid numeric literal at EOF at line 1, column 3 (while parsing '...') at <top-level>, line 1:
      ...
    ERRMSG
  end

  specify 'runtime error' do
    expect do
      JQ('{}').search('.') do |_value|
        raise 'runtime error'
      end
    end.to raise_error(RuntimeError)
  end

  specify 'runtime halt in jq raises error' do
    expect do
      JQ('{}').search('.data | keys') do |value|
        value
      end
    end.to raise_error(JQ::Error).with_message('null (null) has no keys')
  end

  specify 'query for hash' do
    src = { 'FOO' => 100, 'BAR' => [200, 200] }

    expect(src.jq('.BAR[]')).to eq([200, 200])

    src.jq('.BAR[]') do |value|
      expect(value).to eq(200)
    end
  end

  specify 'query for array' do
    src = ['FOO', 100, 'BAR', [200, 200]]

    expect(src.jq('.[3][]')).to eq([200, 200])

    src.jq('.[3][]') do |value|
      expect(value).to eq(200)
    end
  end

  specify 'error in block' do
    expect do
      JQ('[1,2,3]').search('.[]') do |_value|
        1 / 0
      end
    end.to raise_error(ZeroDivisionError)
  end
end
