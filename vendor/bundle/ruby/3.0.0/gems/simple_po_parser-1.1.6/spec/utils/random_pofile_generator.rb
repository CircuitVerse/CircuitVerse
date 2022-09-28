module SimplePoParser
  module RandomPoFileGenerator
    require 'securerandom'
    def self.generate_file(file_path, length = 1000, obsoletes = 10)
      header = "# PO benchmark file header
#
#, fuzzy
msgid \"\"
msgstr \"\"
\"Project-Id-Version: somehwat master\\n\"
\"Report-Msgid-Bugs-To: \\n\"
\"Last-Translator: last t <last.transh@e.mail>\\n\"
\"Language-Team: team\\n\"
\"Content-Type: text/plain; charset=UTF-8\\n\"
\"MIME-Version: 1.0\\n\"
\"Content-Transfer-Encoding: 8bit\\n\"
\"Plural-Forms: nplurals=1; plural=0;\\n\""

      @random = Random.new
      File.open(file_path, 'w+') do |file|
        file.write header
        file.write "\n\n"
        for i in 0..length-obsoletes do
          file.write generate_random_message
        end

        for i in 0...obsoletes do
          file.write generate_random_message(true)
        end
      end

    end

    private

    def self.generate_random_message(obsolete = false)
      random_message = ""

      untranslated_chance = 0.05
      fuzzy_chance = 0.1
      plural_chance = 0.1
      multiline_chance = 0.1
      translator_comment_chance = 0.2
      extracted_comment_chance = 0.05
      msgctxt_chance = 0.9
      reference_chance = 0.9
      multiple_reference_chance = 0.1

      plural = @random.rand < plural_chance ? true : false
      untranslated = @random.rand < untranslated_chance ? true : false
      fuzzy = !untranslated && @random.rand < fuzzy_chance ? true : false
      multiline = @random.rand < multiline_chance ? true : false
      translator_comment = @random.rand < translator_comment_chance ? true : false
      extracted_comment = @random.rand < extracted_comment_chance ? true : false
      reference = @random.rand < reference_chance ? true : false
      multiple_reference = @random.rand < multiple_reference_chance ? true : false
      with_msgctxt = @random.rand < msgctxt_chance ? true : false

      msgctxt = with_msgctxt ? SecureRandom.base64((@random.rand*70.0).ceil) : nil
      if multiline
        lines = (@random.rand*4.0).ceil
        msgid = []
        msgstr = []
        for i in 0..lines
          msgid[i] = SecureRandom.base64((@random.rand*70.0).ceil)
          msgstr[i] = SecureRandom.base64((@random.rand*70.0).ceil)
        end
      else
        msgid = SecureRandom.base64((@random.rand*150.0).ceil)
        msgstr = SecureRandom.base64((@random.rand*150.0).ceil)
      end
      if plural
        if multiline
          msgid_plural = []
          msgstr_plural = []
          for i in 0..lines
            msgid_plural[i] = SecureRandom.base64((@random.rand*70.0).ceil)
            msgstr_plural[i] = SecureRandom.base64((@random.rand*70.0).ceil)
          end
        else
          msgid_plural = SecureRandom.base64((@random.rand*150.0).ceil)
          msgstr_plural = SecureRandom.base64((@random.rand*70.0).ceil)
        end
      end

      random_message += "# #{SecureRandom.base64((@random.rand*50.0).to_i)}\n" if translator_comment
      random_message += "#. #{SecureRandom.base64((@random.rand*50.0).to_i)}\n" if extracted_comment
      random_message += "#: #{SecureRandom.base64((@random.rand*50.0).to_i)}\n" if reference
      if multiple_reference
        references = (@random.rand*3.0).ceil
        for i in 0..references
          random_message += "#: #{SecureRandom.base64((@random.rand*50.0).to_i)}\n"
        end
      end
      if fuzzy
        random_message += "#, fuzzy\n"
        random_message += "##{"~" if obsolete}| msgctxt \"#{msgctxt}\"\n" if msgctxt
        if msgid.is_a?(Array)
          random_message += "##{"~" if obsolete}| msgid \"\"\n"
          msgid.each do |line|
            random_message += "##{"~" if obsolete}| \"#{line}\\n\"\n"
          end
        else
          random_message += "##{"~" if obsolete}| msgid \"#{msgid}\"\n"
        end
        if plural
          if msgid_plural.is_a?(Array)
            random_message += "##{"~" if obsolete}| msgid_plural \"\"\n"
            msgid_plural.each do |line|
              random_message += "##{"~" if obsolete}| \"#{line}\\n\"\n"
            end
          else
            random_message += "##{"~" if obsolete}| msgid_plural \"#{msgid_plural}\"\n"
          end
        end
      end
      random_message += "#{"#~ " if obsolete}msgctxt \"#{msgctxt}\"\n" if msgctxt
      if msgid.is_a?(Array)
        random_message += "#{"#~ " if obsolete}msgid \"\"\n"
        msgid.each do |line|
          random_message += "#{"#~ " if obsolete}\"#{line}\\n\"\n"
        end
      else
        random_message += "#{"#~ " if obsolete}msgid \"#{msgid}\"\n"
      end
      if plural
        if msgid_plural.is_a?(Array)
          random_message += "#{"#~ " if obsolete}msgid_plural \"\"\n"
          msgid_plural.each do |line|
            random_message += "#{"#~ " if obsolete}\"#{line}\\n\"\n"
          end
        else
          random_message += "#{"#~ " if obsolete}msgid_plural \"#{msgid_plural}\"\n"
        end
        if untranslated
          random_message += "#{"#~ " if obsolete}msgstr[0] \"\"\n"
          random_message += "#{"#~ " if obsolete}msgstr[1] \"\"\n"
        else
          if msgstr.is_a?(Array)
            random_message += "#{"#~ " if obsolete}msgstr[0] \"\"\n"
            msgstr.each do |line|
              random_message += "#{"#~ " if obsolete}\"#{line}\\n\"\n"
            end
          else
            random_message += "#{"#~ " if obsolete}msgstr[0] \"#{msgstr}\"\n"
          end
          if msgstr_plural.is_a?(Array)
            random_message += "#{"#~ " if obsolete}msgstr[1] \"\"\n"
            msgstr_plural.each do |line|
              random_message += "#{"#~ " if obsolete}\"#{line}\\n\"\n"
            end
          else
            random_message += "#{"#~ " if obsolete}msgstr[1] \"#{msgstr}\"\n"
          end
        end
      else
        if untranslated
            random_message += "#{"#~ " if obsolete}msgstr \"\"\n"
        else
          if msgstr.is_a?(Array)
            random_message += "#{"#~ " if obsolete}msgstr \"\"\n"
            msgstr.each do |line|
              random_message += "#{"#~ " if obsolete}\"#{line}\\n\"\n"
            end
          else
            random_message += "#{"#~ " if obsolete}msgstr \"#{msgstr}\"\n"
          end
        end
      end
      random_message += "\n"
      random_message
    end

  end
end
