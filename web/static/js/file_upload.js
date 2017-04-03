import UploadStatusBar from './upload_status_bar'
const debug = true

class FileUpload {
  constructor() {
    this.register_events()
  }
  // readURL(input) {
  //   console.log('input', input)
  //   if (input.files && input.files[0]) {
  //     var reader = new FileReader();
  //     console.log('the file', input.files[0])

  //     reader.onload = function (e) {
  //       // $('#upload-preview').attr('src', e.target.result);
  //       $('.upload-preview-file').css('background-image', 'url(' + e.target.result + ')');
  //     }

  //     reader.readAsDataURL(input.files[0]);
  //     this.upload_file(input.files[0])
  //   }
  // }
  readAsDataURL(file, callback) {
    let reader = new FileReader()
    reader.onload = (ev) => {
      callback(ev.target.result, file)
    }
    console.log('file...', file)

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
    console.log('files', files)
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

      let text = `
        <div class='upload-preview'>
          <div class='upload-preview-file'></div>
        </div>
        <div class='upload-preview-title'>
          <input id='file-name' style='display: inherit;' value='${file.name}' placeholder='Filename'>
          <input id='file-description' style='display: inherit;' value="" placeholder="File description">
        </div>
      `
      console.log('file', file)
      sweetAlert({
        title: 'Upload file?',
        text: text,
        showCancelButton: true,
        closeOnConfirm: true,
        closeOnCancel: true,
        html: true
      },
      isConfirm =>  {
        console.log('isConfirm', isConfirm, document.getElementById('file-name').value)
        this.consume()
        if (!isConfirm) {
          return
        }
        let fd = new FormData()
        fd.append('file', file)
        fd.append('body', document.getElementById('file-description').value)
        fd.append('channel_id', ucxchat.channel_id)
        fd.append('user_id', ucxchat.user_id)
        let status = new UploadStatusBar(file.name, 10000);
        this.sendFileToServer(fd, status)
      })
      $('.upload-preview-file').css('background-image', 'url(' + fileContent + ')');
    })
  }
  register_events() {
    $('body').on('change', '.message-form input[type=file]', function() {
      fileUpload.readURL(this)
    })
    $('body').on('click', '.attachment .collapse-switch.icon-right-dir', e => {
      console.log('click right')
      $(e.currentTarget).removeData('collapsed').removeClass('icon-right-dir').addClass('icon-down-dir')
      $(e.currentTarget).closest('.attachment-block').find('.attachment-image').show()
    })
    $('body').on('click', '.attachment .collapse-switch.icon-down-dir', e => {
      console.log('click down')
      $(e.currentTarget).data('collapsed', 'true').addClass('icon-right-dir').removeClass('icon-down-dir')
      $(e.currentTarget).closest('.attachment-block').find('.attachment-image').hide()
    })
  }
  // readURL(input) {
  //   console.log('input', input)
  //   if (input.files && input.files[0]) {
  //     var reader = new FileReader();
  //     console.log('the file', input.files[0])

  //     reader.onload = function (e) {
  //       // $('#upload-preview').attr('src', e.target.result);
  //       $('.upload-preview-file').css('background-image', 'url(' + e.target.result + ')');
  //     }

  //     reader.readAsDataURL(input.files[0]);
  //     this.upload_file(input.files[0])
  //   }
  // }
  sendFileToServer(formData,status) {
    var uploadURL ="/uploads/create"; //Upload URL
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
        //$("#status1").append("File upload Done<br>");
      }
    });
    status.setCancel(jqXHR);
  }

  handleFileUpload(fileList,obj)
  {
    console.log('input files', fileList)
    this.obj = obj
    let files = []
    for (var i = 0; i < fileList.length; i++)
    {
      console.log('pushing', i, fileList[i])
      files.push(fileList[i])
    }

    //   // let file = files[i]
    //   // var fd = new FormData();
    //   // fd.append('file', files[i]);

    //   // // this.sendFileToServer(fd,status);
    //   // this.upload_file(file, fd)
    // }
    console.log('files', files, files[0])
    this.files = files
    this.consume()
  }
}

export default FileUpload
