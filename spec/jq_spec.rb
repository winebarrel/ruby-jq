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

  it 'composition' do
    src = <<-EOS
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
    EOS

    expected = {
      "glossary"=>
        {"GlossDiv"=>
          {"GlossList"=>
            {"GlossEntry"=>
              {"GlossSee"=>"markup",
               "GlossDef"=>
                {"GlossSeeAlso"=>["GML", "XML"],
                 "para"=>
                  "A meta-markup language, used to create markup languages such as DocBook."},
               "Abbrev"=>"ISO 8879:1986",
               "Acronym"=>"SGML",
               "GlossTerm"=>"Standard Generalized Markup Language",
               "SortAs"=>"SGML",
               "ID"=>"SGML"}},
           "title"=>"S"},
         "title"=>"example glossary"}}

    expect(JQ(src).search('.')).to eq([expected])

    JQ(src).search('.') do |value|
      expect(value).to eq(expected)
    end
  end

  it 'read from file' do
    Tempfile.open("ruby-jq.spec.#{$$}") do |src|
      src.puts(<<-EOS)
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
      EOS

      expected = {
        "glossary"=>
          {"GlossDiv"=>
            {"GlossList"=>
              {"GlossEntry"=>
                {"GlossSee"=>"markup",
                 "GlossDef"=>
                  {"GlossSeeAlso"=>["GML", "XML"],
                   "para"=>
                    "A meta-markup language, used to create markup languages such as DocBook."},
                 "Abbrev"=>"ISO 8879:1986",
                 "Acronym"=>"SGML",
                 "GlossTerm"=>"Standard Generalized Markup Language",
                 "SortAs"=>"SGML",
                 "ID"=>"SGML"}},
             "title"=>"S"},
           "title"=>"example glossary"}}

      expect(JQ(src).search('.')).to eq([expected])

      JQ(src).search('.') do |value|
        expect(value).to eq(expected)
      end
    end
  end

  it 'read from file (> 4096)' do
    Tempfile.open("ruby-jq.spec.#{$$}") do |src|
      src.puts('[' + (1..10).map { (<<-EOS) }.join(',') + ']')
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
      EOS

      expected = (1..10).map do
        {
          "glossary"=>
            {"GlossDiv"=>
              {"GlossList"=>
                {"GlossEntry"=>
                  {"GlossSee"=>"markup",
                   "GlossDef"=>
                    {"GlossSeeAlso"=>["GML", "XML"],
                     "para"=>
                      "A meta-markup language, used to create markup languages such as DocBook."},
                   "Abbrev"=>"ISO 8879:1986",
                   "Acronym"=>"SGML",
                   "GlossTerm"=>"Standard Generalized Markup Language",
                   "SortAs"=>"SGML",
                   "ID"=>"SGML"}},
               "title"=>"S"},
             "title"=>"example glossary"}}
      end

      expect(JQ(src).search('.')).to eq([expected])

      JQ(src).search('.') do |value|
        expect(value).to eq(expected)
      end
    end
  end

  it 'parse_json => false' do
    src = <<-EOS
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
    EOS

    expected = '{"glossary":{"GlossDiv":{"GlossList":{"GlossEntry":{"GlossSee":"markup","GlossDef":{"GlossSeeAlso":["GML","XML"],"para":"A meta-markup language, used to create markup languages such as DocBook."},"Abbrev":"ISO 8879:1986","Acronym":"SGML","GlossTerm":"Standard Generalized Markup Language","SortAs":"SGML","ID":"SGML"}},"title":"S"},"title":"example glossary"}}'

    expect(JQ(src, :parse_json => false).search('.')).to eq([expected])

    JQ(src, :parse_json => false).search('.') do |value|
      expect(value).to eq(expected)
    end
  end

  it 'each value' do
    src = <<-EOS
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
    EOS

    expect(JQ(src).search('.menu.popup.menuitem[].value')).to eq(["New", "Open", "Close"])
  end

  it 'compile error' do
    expect {
      JQ('{}').search('...')
    }.to raise_error(JQ::Error)
  end

  it 'runtime error' do
    expect {
      JQ('{}').search('.') do |value|
        raise 'runtime error'
      end
    }.to raise_error(RuntimeError)
  end
end
