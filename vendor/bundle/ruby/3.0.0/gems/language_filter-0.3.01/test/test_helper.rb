require 'minitest/autorun'
require 'minitest/pride'
require File.expand_path('../../lib/language_filter.rb', __FILE__)

def valid_non_empty_list?(list)
  list.must_be_kind_of Array
  list.wont_be_empty
  list.each {|list_item| list_item.must_be_kind_of String}
end

def test_against_word_lists
  word_lists = [
    { # The simpsons word list
      name: "simpsons-5000",
      contents: File.read(File.dirname(__FILE__) + '/lists/simpsons-5000.txt'),
      expected: 
      {
        normal: [
          {
            name: :hate,
            results: ["bitch","bastard"]
          },
          {
            name: :profanity,
            results: ["ass","bastard","bitch"]
          },
          {
            name: :sex,
            results: ["sex","sexy","sexual","cocks","ass","wiener","boobs","gay"]
          },
          {
            name: :violence,
            results: ["stab","kill","killed","killing","killer","kills","murder","murdered","murderer","murderous","gun","guns","gunshot","gunfire","gunshots","death"]
          }
        ],
        creative: [
          {
            name: :hate,
            results: ["bitch","bastard"]
          },
          {
            name: :profanity,
            results: ["ass","bastard","bitch"]
          },
          {
            name: :sex,
            results: ["sex","sexy","sexual","cocks","ass","wiener","boobs","gay"]
          },
          {
            name: :violence,
            results: ["stab","kill","killed","killing","killer","kills","murder","murdered","murderer","murderous","gun","guns","gunshot","gunfire","gunshots","death"]
          }
        ]
      }
    }, { # Wiktionary's 50000 most commons words
      name: "wiktionary-50000",
      contents: File.read(File.dirname(__FILE__) + '/lists/wiktionary-50000.txt'),
      expected: 
      {
        normal: [
          {
            name: :hate,
            results: ["fagots","fagged","faggots","bitch","bastard","Bastard"]
          },
          {
            name: :profanity,
            results: ["ass","asses","Ass","bastard","Bastard","bitch","fagots","fagged","faggots"],
          },
          {
            name: :sex,
            results: ["sex","sexual","sexes","Sex","Sexual","cock","cocks","Cock","Dick","DICK","ass","Ass","penis","prick","pricks","manhood","breast","breasts","cleavage","muff","Homo","homo","slut","whore","gay","Gay","dyke","Dyke","dykes","fagots","fagged","faggots","puberty"]
          },
          {
            name: :violence,
            results: ["stab","stabs","killed","kill","killing","kills","Kill","Killed","murder","murdered","murderer","murderous","murderers","murders","Murder","murdering","guns","gun","gunpowder","gunners","gunboats","gunner","Gun","gunboat","Guns","death","Death","DEATH"]
          }
        ],
        creative: [
          {
            name: :hate,
            results: ["fagots","fagged","faggots","Kunti","kunt","bitch","bastard","Bastard"]
          },
          {
            name: :profanity,
            results: ["assez","ass","asses","Ass","bastard","Bastard","bitch","Kunti","kunt","fagots","fagged","faggots"]
          },
          {
            name: :sex,
            results: ["sex","sexual","sexes","Sex","Sexual","cock","cocks","Cock","Dick","DICK","ass","Ass","penis","prick","pricks","manhood","breast","breasts","cleavage","muff","Kunti","kunt","Homo","homo","slut","whore","gay","Gay","dyke","Dyke","dykes","fagots","fagged","faggots","puberty"]
          },
          {
            name: :violence,
            results: ["stabbed","stab","stabbing","stabs","killed","kill","killing","kills","Kill","Killed","kill'd","murder","murdered","murderer","murderous","murderers","murders","Murder","murdering","guns","gun","gunpowder","gunners","gunboats","gunner","Gun","gunboat","Guns","death","Death","DEATH"]
          }
        ]
      }
    }
  ]
  word_lists.each do |wordlist|
    wordlist[:expected][:normal].each do |matchlist|
      filter = LanguageFilter::Filter.new(matchlist: matchlist[:name], creative_letters: false)
      filter.matched(wordlist[:contents]).must_be :==, matchlist[:results],
        "expected\n#{filter.matched(wordlist[:contents])}\nto be\n#{matchlist[:results]}\nwhile testing normal #{matchlist[:name]} against #{wordlist[:name]}"
    end
    wordlist[:expected][:creative].each do |matchlist|
      filter = LanguageFilter::Filter.new(matchlist: matchlist[:name], creative_letters: true)
      filter.matched(wordlist[:contents]).must_be :==, matchlist[:results],
        "expected\n#{filter.matched(wordlist[:contents])}\nto be\n#{matchlist[:results]}\nwhile testing creative #{matchlist[:name]} against #{wordlist[:name]}"
    end
  end
end