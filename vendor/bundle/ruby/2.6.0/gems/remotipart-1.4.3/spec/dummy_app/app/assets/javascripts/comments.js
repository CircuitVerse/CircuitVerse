$(document)
  .delegate('#new-comment-link, #new-comment-attachment-link', 'ajax:success', function(e, data, status, xhr){
    var $this = $(this),
        $container = $('#new-comment-links'),
        $responseText = $(xhr.responseText),
        $cancelButton = $responseText.find('#cancel-button');
    $container.replaceWith($responseText)
    $cancelButton.click(function(e){
      $cancelButton.parent().replaceWith($container);
      e.preventDefault();
    });
  })
  .delegate('form[data-remote]', 'ajax:aborted:required', function(){
    var $form = $(this),
        errorDivId = 'ajax-validation-errors',
        $errorDiv = $form.find('#' + errorDivId);
    if ( ! $errorDiv.length ) {
      $errorDiv = $('<div>', { id: errorDivId});
      $form.prepend($errorDiv)
    }
    $errorDiv.html($('<h2>', {
      text: 'You must fill in all required fields!'
    }));
  })
  .delegate('form[data-remote]', 'ajax:error', function(e, xhr, status, statusText) {
    $('#comments').after('Error status code: ' + xhr.status + ', Error status message: ' + statusText);
  });

