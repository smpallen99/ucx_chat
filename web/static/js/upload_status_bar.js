const maxFnameLen = 25

class UploadStatusBar {
  constructor(fileName, size) {
    let fname = fileName
    if (fname.length > maxFnameLen)
      fname = fname.slice(0, maxFnameLen - 3) + '...'
    this.fileName = fileName
    this.fileNameStr = fname
    this.progress = '0%'
    this.setSize(size)
    this.create()
  }

  create() {
    $('.container-bars').addClass('show').append(this.template())
    this.elem = $('.container-bars .upload-progress').last()
  }

  close() {
    this.elem.hide()
    this.elem.remove()
  }

  setCancel(jqxhr) {
    this.elem.find('button').click(e => {
      // jqxhr.abort()
      this.elem.hide()
      this.elem.remove()
      console.log('clicked', this.fileName)
    })
  }

  template() {
    return `
    <div class="upload-progress color-primary-action-color background-component-color">
      <div class="upload-progress-progress" style="width: ${this.progress};"></div>
      <div class="upload-progress-text">
        ${this.fileNameStr}
        <span class="progress">${this.progress}</span>
        <span class='size'>${this.sizeStr}</span>
        <button>cancel</button>
      </div>
    </div>
    `
  }

  updateProgress(value) {
    this.progress = value + '%'
    $(this.elem).find('.upload-progress-progress').css('width', this.progress)
    $(this.elem).find('.progress').text(this.progress)
  }

  setSize(size) {
    let sizeStr="";
    let sizeKB = size/1024;
    if(parseInt(sizeKB) > 1024)
    {
        let sizeMB = sizeKB/1024;
        sizeStr = sizeMB.toFixed(2)+" MB";
    }
    else
    {
        sizeStr = sizeKB.toFixed(2)+" KB";
    }
    this.sizeStr = sizeStr
  }
}

export default UploadStatusBar

window.Bar = UploadStatusBar
