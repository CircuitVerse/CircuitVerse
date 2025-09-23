# frozen_string_literal: true

require "test_helper"

class GlobTest < Minitest::Test
  test "with partial matching" do
    glob = Glob.new(
      en: {editor: "editor", edit: "edit"},
      pt: {editor: "editor", edit: "edit"}
    )

    glob << "*.edit"

    assert_equal ["en.edit", "pt.edit"], glob.paths
  end

  test "with rejecting filter" do
    glob = Glob.new(
      en: {
        messages: {
          hello: "Hello!",
          bye: "Bye!"
        }
      },
      pt: {
        messages: {
          hello: "Olá!",
          bye: "Tchau!"
        }
      }
    )

    glob << "*.messages.*"
    glob << "!*.messages.bye"

    expected = {
      en: {
        messages: {
          hello: "Hello!"
        }
      },
      pt: {
        messages: {
          hello: "Olá!"
        }
      }
    }

    assert_equal ["en.messages.hello", "pt.messages.hello"], glob.paths
    assert_equal expected, glob.to_h
    assert_equal expected, glob.to_hash
  end

  test "with overlapping filters" do
    glob = Glob.new(
      en: {
        messages: {
          hello: "Hello!",
          bye: "Bye!"
        }
      },
      pt: {
        messages: {
          hello: "Olá!",
          bye: "Tchau!"
        }
      }
    )

    glob << "*.messages.*"
    glob << "!*.messages.bye"
    glob << "en.messages.bye"

    expected = {
      en: {
        messages: {
          bye: "Bye!",
          hello: "Hello!"
        }
      },
      pt: {
        messages: {
          hello: "Olá!"
        }
      }
    }

    assert_equal [
      "en.messages.bye",
      "en.messages.hello",
      "pt.messages.hello"
    ], glob.paths
    assert_equal expected, glob.to_h
    assert_equal expected, glob.to_hash
  end

  test "with last component as star" do
    glob = Glob.new(
      user: {name: "USER", email: "EMAIL"},
      repo: {name: "REPO"}
    )

    expected = {user: {name: "USER", email: "EMAIL"}}
    glob << "user.*"

    assert_equal ["user.email", "user.name"], glob.paths
    assert_equal expected, glob.to_hash
  end

  test "with star as the initial component" do
    glob = Glob.new(
      user: {name: "USER", email: "EMAIL"},
      repo: {name: "REPO"}
    )

    expected = {user: {name: "USER"}, repo: {name: "REPO"}}
    glob << "*.name"

    assert_equal ["repo.name", "user.name"], glob.paths
    assert_equal expected, glob.to_hash
  end

  test "with star as the middle component" do
    glob = Glob.new(
      config: {
        user: {name: "USER", email: "EMAIL"},
        site: {name: "SITE", host: "HOST"}
      }
    )

    expected = {config: {user: {name: "USER"}, site: {name: "SITE"}}}
    glob << "config.*.name"

    assert_equal ["config.site.name", "config.user.name"], glob.paths
    assert_equal expected, glob.to_hash
  end

  test "with just a star" do
    expected = {
      config: {
        user: {name: "USER", email: "EMAIL"},
        site: {name: "SITE", host: "HOST"}
      }
    }
    glob = Glob.new(expected)
    glob << "*"

    assert_equal [
      "config.site.host",
      "config.site.name",
      "config.user.email",
      "config.user.name"
    ], glob.paths
    assert_equal expected, glob.to_hash
  end

  test "with mixed stars" do
    glob = Glob.new(
      config: {
        user: {name: "USER", email: "EMAIL"},
        site: {name: "SITE", host: "HOST"}
      }
    )
    glob << "*.site.*"

    expected = {
      config: {
        site: {name: "SITE", host: "HOST"}
      }
    }

    assert_equal [
      "config.site.host",
      "config.site.name"
    ], glob.paths
    assert_equal expected, glob.to_hash
  end

  test "filter includes everything by default" do
    data = {
      config: {
        user: {name: "USER", email: "EMAIL"},
        site: {name: "SITE", host: "HOST"}
      }
    }
    actual = Glob.filter(data)

    assert_equal data, actual
  end

  test "filter using specified filters" do
    data = {
      config: {
        user: {name: "USER", email: "EMAIL"},
        site: {name: "SITE", host: "HOST"}
      }
    }
    expected = {config: {user: {name: "USER"}}}
    actual = Glob.filter(data, ["config.user.name"])

    assert_equal expected, actual
  end

  test "using groups as root key" do
    glob = Glob.new(
      pt: {hello: "Olá!"},
      en: {hello: "Hello!"},
      es: {hello: "¡Hola!"}
    )

    glob << "{pt,en}.*"

    assert_equal ["en.hello", "pt.hello"], glob.paths
  end

  test "using groups in mixed positions" do
    glob = Glob.new(
      pt: {messages: {hello: "Olá!", goodbye: "Tchau!"}},
      en: {messages: {hello: "Hello!", goodbye: "Goodbye!"}},
      es: {messages: {hello: "¡Hola!", goodbye: "¡Adios!"}}
    )

    glob << "{pt,en}.messages.{hello,goodbye}"

    expected = [
      "en.messages.goodbye",
      "en.messages.hello",
      "pt.messages.goodbye",
      "pt.messages.hello"
    ]

    assert_equal expected, glob.paths
  end

  test "with keys that contain dots" do
    data = {
      "keys.with.dots" => "dots",
      node: {
        "more.keys.with.dots" => "more dots"
      }
    }

    glob = Glob.new(data)

    glob << "*"

    assert_equal %w[keys\\.with\\.dots node.more\\.keys\\.with\\.dots],
                 glob.paths
    assert_equal Glob::SymbolizeKeys.call(data), glob.to_h

    assert_equal ({node: {"more.keys.with.dots": "more dots"}}),
                 Glob.filter(data, ["node.more\\.keys\\.with\\.dots"])
  end

  test "sorts set when setting new keys" do
    data = {d: "d", a: "a", b: "b"}

    glob = Glob.new(data)
    glob << "*"

    assert_equal({a: "a", b: "b", d: "d"}, glob.to_h)

    glob.set("c", "c")
    glob.set("e.b1.b2.b3", "e---b")
    glob.set("e.a1.a2.a3", "e---a")

    expected = {
      a: "a", b: "b", c: "c", d: "d",
      e: {a1: {a2: {a3: "e---a"}}, b1: {b2: {b3: "e---b"}}}
    }

    assert_equal(expected, glob.to_h)
    assert_equal ["a", "b", "c", "d", "e.a1.a2.a3", "e.b1.b2.b3"], glob.paths
  end

  test "replaces existing node when setting a new path" do
    glob = Glob.new(a: 1, b: {b1: {b2: 2}})
    glob << "*"
    glob.set("a.a1.a2", 4)
    glob.set("b.b1.b2.b3", {b4: 5})

    expected = {
      a: {a1: {a2: 4}},
      b: {b1: {b2: {b3: {b4: 5}}}}
    }

    assert_equal expected, glob.to_h
    assert_equal ["a.a1.a2", "b.b1.b2.b3.b4"], glob.paths
  end
end
