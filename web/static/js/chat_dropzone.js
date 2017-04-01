$(document).ready(() => {
  window.isAdvancedUpload = function() {
    var div = document.createElement('div');
    return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
  }();
  if (isAdvancedUpload) {
    let droppedFiles = false
    let enterTarget = null;

    $('.dropzone').on('drag dragstart dragend dragover dragenter dragleave drop', e => {
      e.preventDefault()
      e.stopPropagation()
    })
    .on('dragover dragenter', (e) => {
      enterTarget = e.target
      $('.dropzone').addClass('over')
    })
    .on('dragleave dragend drop', (e) => {
      if (enterTarget == e.target) {
        $('.dropzone').removeClass('over')
      }
    })
    .on('drop', e => {
      droppedFiles = e.originalEvent.dataTransfer.files
      console.log('drop', droppedFiles)
    })

  }
})
