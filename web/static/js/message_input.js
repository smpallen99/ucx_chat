import Messages from './messages'

const send_button = `
  <div class='message-buttons send-button'>
    <i class='icon-paper-plane' aria-label='send'></i>
  </div>`

class MessageInput {
  constructor() {
    this.empty = true
    this.register_events()
    this.save = undefined
  }
  restore_buttons() {
    $('.message-buttons').remove()
    $('.message-input').append(this.save)
    this.empty = true
  }
  add_send_button() {
    this.save = $('.message-buttons')
    $('.message-buttons').remove()
    $('.message-input').append(send_button)
    this.empty = false
  }
  register_events() {
    $('body')
    .on('click', '.message-buttons.send-button', e => {
      this.restore_buttons()
      Messages.send_message($('.message-form-text').val())
    })
    .on('keyup', '.message-input', e => {
      if ($('textarea.input-message').val().length == 0) {
        if (!this.empty) {
          this.restore_buttons()
        }
      } else {
        if (this.empty) {
          this.add_send_button()
        }
      }
    })
  }
}

export default MessageInput
