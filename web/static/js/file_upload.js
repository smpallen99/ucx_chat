import UploadStatusBar from './upload_status_bar'
import toastr from 'toastr'
require('./file_upload_restrictions.js')

const debug = true

class FileUpload {
  constructor() {
    this.register_events()
  }
  readAsDataURL(file, callback) {
    let reader = new FileReader()
    reader.onload = (ev) => {
      callback(ev.target.result, file)
    }

    reader.readAsDataURL(file)
  }

  readAsArrayBuffer(file, callback) {
    let reader = new FileReader()
    reader.onload = (ev) => {
      callback(ev.target.result, file)
    }
    reader.readAsArrayBuffer(file)
  }

  fileUploadIsValidContentType(file) {
    return true
  }

  upload_files(files) {
    files.forEach((file, i) => {
      this.upload_file(file)
    })
  }
  upload_file(file, fd) {
  }

  consume() {
    let file = this.files.pop()

    if (!file) {
      swal.close()
      return
    }

    if (!this.validate_upload(file)) {
      swal.close()
      return
    }

    this.readAsDataURL(file, (fileContent) => {
      if (!this.fileUploadIsValidContentType(file.type)) {
        swal({
          title: 'FileUpload MediaType NotAccepted',
          text: file.type,
          type: 'error',
          timer: 3000
        })
        return
      }

      if (file.file == 0) {
        swal({
          title: 'File Empty',
          type: 'error',
          timer: 1000
        })
        return
      }
      let text = ''

      // let filename = file.name.replace(/\.[^/.]+$/, "")
      let filename = file.name

      if (file.type.startsWith('video')) {
        text = `
          <div class='upload-preview'>
            <video  style="width: 100%;" controls="controls">
              <source src="${fileContent}" type="video/webm">
              Your browser does not support the video element.
            </video>
          </div>
          <div class='upload-preview-title'>
            <input id='file-name' style='display: inherit;' value='${_.escape(filename)}' placeholder='Filename'>
            <input id='file-description' style='display: inherit;' value="" placeholder="File description">
          </div>`
      } else if (file.type.startsWith('audio')) {
        text = `
          <div class='upload-preview'>
            <audio  style="width: 100%;" controls="controls">
              <source src="${fileContent}" type="audio/wav">
              Your browser does not support the audio element.
            </audio>
          </div>
          <div class='upload-preview-title'>
            <input id='file-name' style='display: inherit;' value='${_.escape(filename)}' placeholder='Filename'>
            <input id='file-description' style='display: inherit;' value="" placeholder="File description">
          </div>`
      } else {
        text = `
          <div class='upload-preview'>
            <div class='upload-preview-file' style='background-image: url(${fileContent})'></div>
          </div>
          <div class='upload-preview-title'>
            <input id='file-name' style='display: inherit;' value='${_.escape(filename)}' placeholder='Filename'>
            <input id='file-description' style='display: inherit;' value="" placeholder="File description">
          </div>`
      }

      sweetAlert({
        title: 'Upload file?',
        text: text,
        showCancelButton: true,
        closeOnConfirm: true,
        closeOnCancel: true,
        html: true
      },
      isConfirm =>  {
        // console.log('isConfirm', isConfirm, document.getElementById('file-name').value)
        setTimeout(() => {
          this.consume()
        }, 400)
        if (!isConfirm) {
          return
        }
        let fd = new FormData()
        fd.append('file', file)
        fd.append('type', file.type)
        fd.append('file_name', document.getElementById('file-name').value)
        fd.append('description', document.getElementById('file-description').value)
        fd.append('channel_id', ucxchat.channel_id)
        fd.append('user_id', ucxchat.user_id)
        let status = new UploadStatusBar(file.name, 10000);
        this.sendFileToServer(fd, status)
      })
      $('#file-description').focus()
    })
  }
  validate_upload(file) {
    let size = UcxChat.settings.maximum_file_upload_size_kb * 1024
    if (file.size > size) {
      console.log('file sizes', file.size, size)
      toastr.error('File size exceeds the ' + UcxChat.settings.maximum_file_upload_size_kb + 'KB maximum!')
      return false
    }
    if (!UcxChat.fileUploadIsValidContentType(file.type)) {
      console.log('file.type', file.type)
      toastr.error('Restricted file type')
      return false
    }
    return true
  }

  register_events() {
    $('body').on('change', '.message-form input[type=file]', function(event) {
      let e = event.originalEvent || event
      let files = e.target.files
      if (!files || files.length == 0) {
        files = e.dataTransfer.files || []
      }
      fileUpload.handleFileUpload(files)
    })
    $('body').on('click', '.attachment .collapse-switch.icon-right-dir', e => {
      $(e.currentTarget).removeData('collapsed').removeClass('icon-right-dir').addClass('icon-down-dir')
      $(e.currentTarget).closest('.attachment-block').find('.media-container').show()
    })
    $('body').on('click', '.attachment .collapse-switch.icon-down-dir', e => {
      $(e.currentTarget).data('collapsed', 'true').addClass('icon-right-dir').removeClass('icon-down-dir')
      $(e.currentTarget).closest('.attachment-block').find('.media-container').hide()
    })
  }
  sendFileToServer(formData,status) {
    console.warn('formData', formData)
    var uploadURL ="/attachments/create"; //Upload URL
    var extraData ={}; //Extra Data.
    var jqXHR=$.ajax({
      xhr: function() {
        var xhrobj = $.ajaxSettings.xhr();
        if (xhrobj.upload) {
          xhrobj.upload.addEventListener('progress', function(event) {
            var percent = 0;
            var position = event.loaded || event.position;
            var total = event.total;
            if (event.lengthComputable) {
              percent = Math.ceil(position / total * 100);
            }
            //Set progress
            status.updateProgress(percent);
          }, false);
        }
        return xhrobj;
      },
      url: uploadURL,
      type: "POST",
      contentType:false,
      processData: false,
      cache: false,
      data: formData,
      success: function(data){
        status.updateProgress(100);
        setTimeout(() => {
          status.close()
        }, 2000)
      },
      error: function (xhr, textStatus, error) {
        status.close()
        toastr.error('There was a problem uploading your file')
      }
    });
    status.setCancel(jqXHR);
  }

  handleFileUpload(fileList,obj)
  {
    this.obj = obj
    let files = []
    for (var i = 0; i < fileList.length; i++)
    {
      files.push(fileList[i])
    }

    this.files = files
    this.consume()
  }
}

export default FileUpload
