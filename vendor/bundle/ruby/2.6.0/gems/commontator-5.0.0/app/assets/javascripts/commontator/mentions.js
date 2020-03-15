window.Commontator = {};
Commontator._ = window._.noConflict();
Commontator.initMentions = function() {
    $('.comment_form_field textarea:not(.mentions-added)').each(function(_index, textarea){
        $textarea = $(textarea);
        $form = $textarea.parents('form');
        threadId = $textarea.parents('.thread').attr('id').match(/[\d]+/)[0];
        $textarea.addClass('mentions-added');
        currentValue = $textarea.val();
        $textarea.mentionsInput({
            elastic: false,
            showAvatars: false,
            allowRepeat: true,
            minChars: 3,
            onDataRequest:function (mode, query, callback) {
                $.getJSON('/commontator/threads/'+threadId+'/mentions.json', {q: query}, function(responseData) {
                    callback.call(this, responseData.mentions);
                });
            }
        });
        $textarea.val(currentValue);
        $textarea.on('focusout', function(){
            $textarea.mentionsInput('getMentions', function(mentions){
                $form.find('input[name="mentioned_ids[]"]').remove();
                $(mentions).each(function(_index, mention){
                    $input = $('<input>', { type: 'hidden', name: 'mentioned_ids[]', value: mention.id });
                    $form.append($input)
                });
            });
        });
    });
};
