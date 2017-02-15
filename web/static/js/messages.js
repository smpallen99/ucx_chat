class Messages {

  static new_message(msg) {
    $('.messages-box .wrapper > ul').append(msg.html)

    this.scroll_bottom()


    if (ucxchat.client_id == msg.client_id) {
      console.log('adding own to', msg.id, $('#' + msg.id))
      $('#' + msg.id).addClass("own")
    }
  }
  static scroll_bottom() {
    let mypanel = $('.messages-box .wrapper')
    myPanel.scrollTop(myPanel[0].scrollHeight - myPanel.height());
  }

  static send_message(msg) {
    let user = window.ucxchat.user_id
    let ucxchat = window.ucxchat
    // console.log('user', user)

    roomchan.push("message", {message: msg, user_id: user, room: ucxchat.room, nickname: ucxchat.nickname,
      client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})

    $('.message-form-text').val('')
  }
}
export default Messages;
