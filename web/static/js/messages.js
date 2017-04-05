import * as cc from "./chat_channel"
import hljs from "highlight.js"
import * as utils from "./utils"
import * as main from "./main"

const debug = true;

class Messages {
  constructor() {
  }

  static new_message(msg) {
    let html = msg.html

    let at_bottom = roomManager.at_bottom
    if (debug) console.log('new_message', msg)
    $('.messages-box .wrapper > ul').append(html)

    let last = $(`#${msg.id} .body`)
    if (last.text().trim() == "") {
      last.find('img.emojione').addClass('big')
    }

    $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
      console.log('block', block)
      hljs.highlightBlock(block)
    })

    if (ucxchat.user_id == msg.user_id) {
      if (debug) { console.log('adding own to', msg.id, $('#' + msg.id)) }
      $('#' + msg.id).addClass("own")
      main.run()
    }
    main.update_mentions(msg.id)

    if (at_bottom || msg.user_id == ucxchat.user_id) {
      utils.scroll_bottom()
    }

    roomManager.new_message(msg.id, msg.user_id)
  }
  static update_message(msg) {
    $('#' + msg.id).replaceWith(msg.html)
      .find('pre').each(function(i, block) {
        hljs.highlightBlock(block)
      })

    if (ucxchat.user_id == msg.user_id) {
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
    if (msg.update) {
      cc.put("/messages/" + msg.update, {message: msg.value.trim(), user_id: user})
        .receive("ok", resp => {
          $('.message-form-text').removeClass('editing')
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
              hljs.highlightBlock(block)
            })
            utils.scroll_bottom()
            // console.log('got response from send message')
          }
        })
        .receive("error", resp => {
          let error = resp.error
          if (!error) {
            error = "Problem editing message"
          }
          toastr.error(error)
          $('.message-form-text').removeClass('editing')
        })

    } else if (msg.startsWith('/')) {
      let match = msg.match(/^\/([^\s]+)(.*)/)
      let route = "/slashcommand/" + match[1]
      cc.put(route, {args: match[2].trim()})
        .receive("ok", resp => {
          // console.log('slash command resp', resp )
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            utils.scroll_bottom()
          }
        })

      roomManager.remove_unread()

    } else if (!utils.empty_string(msg.trim())) {
      cc.post("/messages", {message: msg.trim(), user_id: user})
        .receive("ok", resp => {
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
              hljs.highlightBlock(block)
            })
            Messages.scroll_bottom()
          }
        })

      roomManager.remove_unread()
    }

    $('.message-form-text').val('')
  }
}
export default Messages;
