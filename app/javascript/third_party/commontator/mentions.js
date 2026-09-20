/* Vendored from commontator 7.0.1
 * (vendor/assets/javascripts/mentionsInput/jquery.mentionsInput.js).
 * Loaded via esbuild instead of Sprockets directives. Requires global
 * jQuery and _ (underscore) to be set before this file executes. */
window.Commontator = {};
// NOTE: underscore's UMD build only defines _.noConflict() in its
// global-fallback branch; under a bundler (CJS-detected) the export has no
// noConflict. Nothing else owns window._ here (underscore exists solely for
// the mentions plugin below), so assign directly.
Commontator._ = window._;
Commontator.initMentions = function() {
    $('.commontator .field textarea:not(.mentions-added)').each(function(_index, textarea){
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
                $.getJSON('/commontator/threads/' + threadId + '/mentions.json', {q: query}, function(responseData) {
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
