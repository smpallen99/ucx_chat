$(document).ready(() => {
  window.isAdvancedUpload = function() {
    var div = document.createElement('div');
    return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
  }();
  if (isAdvancedUpload) {
    let droppedFiles = false
    let enterTarget = null;
    let obj = $('.dropzone')

    obj.on('drag dragstart dragend dragover dragenter dragleave drop', e => {
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
    .on('drop', event => {
      // droppedFiles = e.originalEvent.dataTransfer.files
      // console.log('drop', droppedFiles)
      let e = event.originalEvent || event
      let files = e.dataTransfer.files || []
      // console.log('drop event', event, 'e', e, 'files', files)

      // let filesToUpload = []
      // for(var i = 0; i < files.length; i++) {
      //   // Object.defineProperty(file, 'type', { value: mime.lookup(file.name) })
      //   filesToUpload.push(files[i])
      // }
      // fileUpload.readURL({files: filesToUpload})
      fileUpload.handleFileUpload(files, obj)
    })

  }
})
